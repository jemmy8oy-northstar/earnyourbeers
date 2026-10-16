import { useEffect, useRef } from 'react';

interface ModalProps {
  title: string;
  /** Omit for a modal that can only be left through its own buttons (the settlement report). */
  onClose?: () => void;
  children: React.ReactNode;
}

/** A minimal accessible modal: a labelled dialog over a scrim, Escape closes when it may. */
export default function Modal({ title, onClose, children }: ModalProps) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    ref.current?.focus();
    if (!onClose) return;
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div className="eyv-scrim" onMouseDown={(e) => { if (e.target === e.currentTarget) onClose?.(); }}>
      <div className="eyv-modal" role="dialog" aria-modal="true" aria-label={title} tabIndex={-1} ref={ref}>
        {children}
      </div>
    </div>
  );
}
