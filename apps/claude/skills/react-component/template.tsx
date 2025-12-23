/**
 * Module dependencies.
 */

import type { ReactNode } from 'react';

/**
 * Props.
 */

interface ComponentNameProps {
  children: ReactNode;
  className?: string;
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}

/**
 * Export `ComponentName` component.
 */

export function ComponentName({
  children,
  className,
  disabled = false,
  variant = 'primary'
}: ComponentNameProps) {
  return (
    <div
      className={className}
      data-disabled={disabled}
      data-variant={variant}
    >
      {children}
    </div>
  );
}
