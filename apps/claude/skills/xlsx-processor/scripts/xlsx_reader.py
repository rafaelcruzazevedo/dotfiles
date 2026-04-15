#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["openpyxl"]
# ///
"""
XLSX Reader — Read and process Excel spreadsheets with multiple sheets/tabs.

Designed to run via `uv run` which auto-manages dependencies.
Fallback: creates a local venv if uv is not available.

Usage:
    uv run xlsx_reader.py <file.xlsx> --list-sheets
    uv run xlsx_reader.py <file.xlsx> --sheet "Sheet1"
    uv run xlsx_reader.py <file.xlsx> --all
    uv run xlsx_reader.py <file.xlsx> --sheet "Sheet1" --range A1:D10
    uv run xlsx_reader.py <file.xlsx> --sheet "Sheet1" --format json
"""

import argparse
import csv
import io
import json
import os
import subprocess
import sys
from pathlib import Path


def ensure_openpyxl():
    """Ensure openpyxl is available. Uses venv fallback if direct import fails."""
    try:
        import openpyxl  # noqa: F401
        return
    except ImportError:
        pass

    # Create a venv in the skill directory and install openpyxl
    skill_dir = Path(__file__).resolve().parent.parent
    venv_dir = skill_dir / ".venv"

    if not venv_dir.exists():
        print("Creating virtual environment and installing openpyxl...", file=sys.stderr)
        subprocess.check_call([sys.executable, "-m", "venv", str(venv_dir)], stdout=subprocess.DEVNULL)
        venv_pip = venv_dir / "bin" / "pip"
        subprocess.check_call([str(venv_pip), "install", "openpyxl", "--quiet"], stdout=subprocess.DEVNULL)

    # Re-exec with the venv's Python
    venv_python = venv_dir / "bin" / "python"
    os.execv(str(venv_python), [str(venv_python)] + sys.argv)


ensure_openpyxl()

import openpyxl  # noqa: E402
from openpyxl.utils import column_index_from_string, get_column_letter  # noqa: E402


def parse_range(range_str):
    """Parse a cell range like 'A1:D10' into (min_row, min_col, max_row, max_col)."""
    parts = range_str.upper().split(":")
    if len(parts) != 2:
        print(f"Error: Invalid range format '{range_str}'. Use format like 'A1:D10'.", file=sys.stderr)
        sys.exit(2)

    def parse_cell(cell):
        col_str = "".join(c for c in cell if c.isalpha())
        row_str = "".join(c for c in cell if c.isdigit())
        if not col_str or not row_str:
            print(f"Error: Invalid cell reference '{cell}'.", file=sys.stderr)
            sys.exit(2)
        return int(row_str), column_index_from_string(col_str)

    start_row, start_col = parse_cell(parts[0])
    end_row, end_col = parse_cell(parts[1])
    return start_row, start_col, end_row, end_col


def get_cell_value(cell):
    """Extract cell value, handling merged cells and None."""
    if cell.value is None:
        return ""
    return str(cell.value)


def read_sheet(ws, cell_range=None, header_row=None):
    """Read a worksheet into a list of rows (list of strings).

    Returns (headers, rows) if header_row is set, otherwise (None, rows).
    """
    if cell_range:
        min_row, min_col, max_row, max_col = parse_range(cell_range)
    else:
        min_row = ws.min_row or 1
        min_col = ws.min_column or 1
        max_row = ws.max_row or 1
        max_col = ws.max_column or 1

    rows = []
    for row in ws.iter_rows(min_row=min_row, max_row=max_row, min_col=min_col, max_col=max_col):
        rows.append([get_cell_value(cell) for cell in row])

    headers = None
    if header_row is not None:
        idx = header_row - min_row
        if 0 <= idx < len(rows):
            headers = rows[idx]
            rows = rows[idx + 1 :]

    return headers, rows


def format_csv(headers, rows, sheet_name=None):
    """Format data as CSV."""
    output = io.StringIO()
    writer = csv.writer(output)
    if sheet_name:
        writer.writerow([f"# Sheet: {sheet_name}"])
    if headers:
        writer.writerow(headers)
    writer.writerows(rows)
    return output.getvalue()


def format_json(headers, rows, sheet_name=None):
    """Format data as JSON."""
    if headers:
        data = []
        for row in rows:
            record = {}
            for i, h in enumerate(headers):
                key = h if h else f"col_{i + 1}"
                record[key] = row[i] if i < len(row) else ""
            data.append(record)
    else:
        data = rows

    result = {"sheet": sheet_name, "data": data} if sheet_name else {"data": data}
    return json.dumps(result, indent=2, ensure_ascii=False)


def format_markdown(headers, rows, sheet_name=None):
    """Format data as Markdown table."""
    lines = []
    if sheet_name:
        lines.append(f"### {sheet_name}\n")

    all_rows = [headers] + rows if headers else rows
    if not all_rows:
        return "(empty sheet)\n"

    # Calculate column widths
    num_cols = max(len(r) for r in all_rows)
    widths = [3] * num_cols
    for row in all_rows:
        for i, val in enumerate(row):
            if i < num_cols:
                widths[i] = max(widths[i], len(str(val)))

    def format_row(row):
        cells = []
        for i in range(num_cols):
            val = str(row[i]) if i < len(row) else ""
            cells.append(val.ljust(widths[i]))
        return "| " + " | ".join(cells) + " |"

    if headers:
        lines.append(format_row(headers))
        lines.append("| " + " | ".join("-" * w for w in widths) + " |")
        for row in rows:
            lines.append(format_row(row))
    else:
        # Auto-generate header from column letters
        auto_headers = [get_column_letter(i + 1) for i in range(num_cols)]
        lines.append(format_row(auto_headers))
        lines.append("| " + " | ".join("-" * w for w in widths) + " |")
        for row in all_rows:
            lines.append(format_row(row))

    return "\n".join(lines) + "\n"


def list_sheets(wb):
    """List all sheets with dimensions."""
    print(f"Workbook: {len(wb.sheetnames)} sheet(s)\n")
    for i, name in enumerate(wb.sheetnames, 1):
        ws = wb[name]
        rows = ws.max_row or 0
        cols = ws.max_column or 0
        col_range = f"A-{get_column_letter(cols)}" if cols > 0 else "empty"
        print(f"  {i}. {name} ({rows} rows x {cols} cols, columns {col_range})")


def main():
    parser = argparse.ArgumentParser(
        description="Read and process XLSX files with multiple sheets.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s data.xlsx --list-sheets
  %(prog)s data.xlsx --sheet "Sales" --format markdown
  %(prog)s data.xlsx --all --format json
  %(prog)s data.xlsx --sheet "Sales" --range B2:F20 --header-row 2
  %(prog)s data.xlsx --all --format csv --max-rows 50
        """,
    )
    parser.add_argument("file", help="Path to the .xlsx file")
    parser.add_argument("--list-sheets", action="store_true", help="List all sheet names with dimensions")
    parser.add_argument("--sheet", "-s", help="Sheet name or index (1-based) to read")
    parser.add_argument("--all", "-a", action="store_true", help="Read all sheets")
    parser.add_argument("--range", "-r", help="Cell range to read (e.g., A1:D10)")
    parser.add_argument("--format", "-f", choices=["csv", "json", "markdown", "md"], default="markdown", help="Output format (default: markdown)")
    parser.add_argument("--header-row", type=int, help="Row number to use as header (1-based)")
    parser.add_argument("--max-rows", type=int, help="Maximum rows to output per sheet")
    parser.add_argument("--data-only", action="store_true", default=True, help="Read calculated values instead of formulas (default: true)")

    args = parser.parse_args()

    filepath = Path(args.file)
    if not filepath.exists():
        print(f"Error: File '{filepath}' not found.", file=sys.stderr)
        sys.exit(1)

    if not filepath.suffix.lower() in (".xlsx", ".xlsm", ".xltx", ".xltm"):
        print(f"Error: File '{filepath}' is not an Excel file (.xlsx).", file=sys.stderr)
        sys.exit(2)

    try:
        wb = openpyxl.load_workbook(str(filepath), data_only=args.data_only, read_only=True)
    except Exception as e:
        print(f"Error opening workbook: {e}", file=sys.stderr)
        sys.exit(3)

    if args.list_sheets:
        list_sheets(wb)
        wb.close()
        return

    fmt = "markdown" if args.format == "md" else args.format

    sheets_to_read = []

    if args.all:
        sheets_to_read = wb.sheetnames
    elif args.sheet:
        # Support sheet by index (1-based)
        try:
            idx = int(args.sheet) - 1
            if 0 <= idx < len(wb.sheetnames):
                sheets_to_read = [wb.sheetnames[idx]]
            else:
                print(f"Error: Sheet index {args.sheet} out of range (1-{len(wb.sheetnames)}).", file=sys.stderr)
                sys.exit(2)
        except ValueError:
            if args.sheet in wb.sheetnames:
                sheets_to_read = [args.sheet]
            else:
                print(f"Error: Sheet '{args.sheet}' not found.", file=sys.stderr)
                print(f"Available sheets: {', '.join(wb.sheetnames)}", file=sys.stderr)
                sys.exit(2)
    else:
        # Default: read active/first sheet
        sheets_to_read = [wb.sheetnames[0]]

    all_json_results = []

    for sheet_name in sheets_to_read:
        ws = wb[sheet_name]
        headers, rows = read_sheet(ws, cell_range=args.range, header_row=args.header_row)

        if args.max_rows and len(rows) > args.max_rows:
            total = len(rows)
            rows = rows[: args.max_rows]
            truncated = True
        else:
            total = len(rows)
            truncated = False

        show_name = sheet_name if len(sheets_to_read) > 1 else None

        if fmt == "csv":
            print(format_csv(headers, rows, sheet_name=show_name))
        elif fmt == "json":
            all_json_results.append(json.loads(format_json(headers, rows, sheet_name=sheet_name)))
        elif fmt == "markdown":
            print(format_markdown(headers, rows, sheet_name=show_name))

        if truncated:
            print(f"\n(Showing {args.max_rows} of {total} rows)", file=sys.stderr)

    if fmt == "json":
        if len(all_json_results) == 1:
            print(json.dumps(all_json_results[0], indent=2, ensure_ascii=False))
        else:
            print(json.dumps({"sheets": all_json_results}, indent=2, ensure_ascii=False))

    wb.close()


if __name__ == "__main__":
    main()
