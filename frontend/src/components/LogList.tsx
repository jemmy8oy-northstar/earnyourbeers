import { useState } from 'react';
import { errorMessage, useDeleteEntryMutation, useEditEntryMutation, type Dashboard, type Entry } from '../api/eyv';
import { ACTIVITY_UNIT, formatAmount, loggedAt } from '../format';
import AmountDialog from './AmountDialog';

const ICON: Record<string, string> = { Run: '🏃', Cycle: '🚴', Swim: '🏊' };

function describe(e: Entry, emoji: string): string {
  return e.activity
    ? `${e.amount.toFixed(1)} ${ACTIVITY_UNIT[e.activity]} ${e.activity}`
    : `${formatAmount(e.amount)} ${emoji}`;
}

/** BEH-LOG-3: the week's entries, newest first; only the one the API marks editable has actions. */
export default function LogList({ dashboard }: { dashboard: Dashboard }) {
  const [editing, setEditing] = useState<Entry | null>(null);
  const [edit, editState] = useEditEntryMutation();
  const [remove, removeState] = useDeleteEntryMutation();
  const { entries } = dashboard.week;
  const emoji = dashboard.viceEmoji;

  if (entries.length === 0) return <p className="eyv-empty">No activity this week.</p>;

  return (
    <section aria-label="Log history">
      <h3 className="eyv-section">LOG HISTORY</h3>
      <ul className="eyv-log">
        {entries.map((e) => (
          <li key={e.id} className="eyv-log__item">
            <span className="eyv-log__icon" aria-hidden="true">{e.activity ? ICON[e.activity] : emoji}</span>
            <span className="eyv-log__text">
              <span className="eyv-log__label">{describe(e, emoji)}</span>
              <span className="eyv-log__time">{loggedAt(e.loggedAt)}</span>
            </span>
            {e.editable && (
              <span className="eyv-log__actions">
                <button type="button" className="eyv-icon-btn" aria-label="Edit entry" onClick={() => setEditing(e)}>✎</button>
                <button type="button" className="eyv-icon-btn" aria-label="Delete entry" onClick={() => void remove({ id: e.id })}>🗑</button>
              </span>
            )}
          </li>
        ))}
      </ul>
      {removeState.isError && <p className="eyv-error" role="alert">{errorMessage(removeState.error)}</p>}
      {editing && (
        <AmountDialog
          title={editing.activity ? `Edit ${editing.activity} (${ACTIVITY_UNIT[editing.activity]})` : `Edit ${emoji}`}
          initial={editing.amount}
          allowZero
          confirmLabel="Save"
          busy={editState.isLoading}
          error={editState.isError ? errorMessage(editState.error) : undefined}
          onClose={() => { setEditing(null); editState.reset(); }}
          onConfirm={(amount) => void edit({ id: editing.id, amountRequest: { amount } }).unwrap().then(() => setEditing(null), () => undefined)}
        />
      )}
    </section>
  );
}
