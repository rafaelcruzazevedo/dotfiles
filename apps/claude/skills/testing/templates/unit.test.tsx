/**
 * Module dependencies.
 */

import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { ComponentName } from './index';

/**
 * Tests for `ComponentName` component.
 */

describe('ComponentName', () => {
  it('should render children', () => {
    render(<ComponentName>Test content</ComponentName>);

    expect(screen.getByText('Test content')).toBeInTheDocument();
  });

  it('should apply variant class', () => {
    render(<ComponentName variant="secondary">Content</ComponentName>);

    expect(screen.getByText('Content')).toHaveAttribute('data-variant', 'secondary');
  });

  it('should call onClick when clicked', async () => {
    const handleClick = vi.fn();

    render(<ComponentName onClick={handleClick}>Click me</ComponentName>);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('should be disabled when disabled prop is true', () => {
    render(<ComponentName disabled={true}>Disabled</ComponentName>);

    expect(screen.getByRole('button')).toBeDisabled();
  });
});
