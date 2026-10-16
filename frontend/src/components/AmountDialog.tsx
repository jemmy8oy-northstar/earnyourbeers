import { useState } from 'react';
import { Button, Input } from './ui';
import Modal from './Modal';

interface AmountDialogProps {
  title: string;
  initial?: number;
  /** Vice entries must be > 0 when logged; an edit may go down to 0. */
  allowZero: boolean;
  unit?: string;
  confirmLabel: string;
  busy?: boolean;
  error?: string;
  onConfirm: (amount: number) => void;
  onClose: () => void;
}

/** Asks for one number (custom vice amount, or the edit of the newest entry). */
export default function AmountDialog({ title, initial, allowZero, unit, confirmLabel, busy, error, onConfirm, onClose }: AmountDialogProps) {
  const [text, setText] = useState(initial === undefined ? '' : String(initial));
  const [invalid, setInvalid] = useState(false);

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    const n = Number(text);
    const ok = text.trim() !== '' && Number.isFinite(n) && (allowZero ? n >= 0 : n > 0);
    if (!ok) { setInvalid(true); return; }
    onConfirm(n);
  };

  const message = invalid
    ? (allowZero ? 'Enter an amount of 0 or more.' : 'Enter an amount greater than 0.')
    : error;

  return (
    <Modal title={title} onClose={onClose}>
      <form className="eyv-form" onSubmit={submit} noValidate>
        <h2 className="eyv-form__heading">{title}</h2>
        <Input
          label={unit ? `Amount (${unit})` : 'Amount'}
          type="text"
          inputMode="decimal"
          autoFocus
          value={text}
          onChange={(e) => { setText(e.target.value); setInvalid(false); }}
          error={message}
        />
        <div className="eyv-row">
          <Button type="button" variant="ghost" onClick={onClose}>Cancel</Button>
          <Button type="submit" loading={busy}>{confirmLabel}</Button>
        </div>
      </form>
    </Modal>
  );
}
