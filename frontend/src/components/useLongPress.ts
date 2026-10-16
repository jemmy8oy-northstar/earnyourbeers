import { useRef } from 'react';

const HOLD_MS = 500;

/**
 * Tap vs long press on one button (BEH-LOG-1). Spread the result on the element.
 * A long press fires `onLong` once the hold passes 500 ms and suppresses the click that follows
 * the release; anything shorter (and keyboard activation) is an ordinary click -> `onTap`.
 */
export function useLongPress(onTap: () => void, onLong: () => void) {
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const fired = useRef(false);

  const cancel = () => { clearTimeout(timer.current); timer.current = undefined; };

  return {
    onPointerDown: () => {
      fired.current = false;
      cancel();
      timer.current = setTimeout(() => { fired.current = true; timer.current = undefined; onLong(); }, HOLD_MS);
    },
    onKeyDown: () => { fired.current = false; },
    onPointerUp: cancel,
    onPointerLeave: cancel,
    onPointerCancel: cancel,
    // A touch long-press raises the browser's context menu; this is ours instead.
    onContextMenu: (e: React.MouseEvent) => e.preventDefault(),
    onClick: () => {
      if (fired.current) { fired.current = false; return; }
      onTap();
    },
  };
}
