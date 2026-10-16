import { useState } from 'react';
import { errorMessage, useLogActivityMutation, useLogViceMutation, type Dashboard } from '../api/eyv';
import { formatAmount, formatPoints } from '../format';
import AmountDialog from './AmountDialog';
import { useLongPress } from './useLongPress';

const ACTIVITIES = [
  { type: 'Run', icon: '🏃', increment: '+1 km' },
  { type: 'Cycle', icon: '🚴', increment: '+1 km' },
  { type: 'Swim', icon: '🏊', increment: '+1 len' },
] as const;

/** Totals logged this week, for the small number under each button. */
function totals(d: Dashboard) {
  const sum = (pred: (e: Dashboard['week']['entries'][number]) => boolean) =>
    d.week.entries.filter(pred).reduce((s, e) => s + e.amount, 0);
  return {
    vice: sum((e) => e.kind === 'Vice'),
    Run: sum((e) => e.activity === 'Run'),
    Cycle: sum((e) => e.activity === 'Cycle'),
    Swim: sum((e) => e.activity === 'Swim'),
  };
}

/** BEH-LOG-1: one-tap logging. Vice: tap = 1, long press = ask for an amount > 0. */
export default function ActionRow({ dashboard }: { dashboard: Dashboard }) {
  const [logActivity, activityState] = useLogActivityMutation();
  const [logVice, viceState] = useLogViceMutation();
  const [asking, setAsking] = useState(false);
  const t = totals(dashboard);
  const emoji = dashboard.viceEmoji;

  const press = useLongPress(
    () => void logVice({ amountRequest: { amount: 1 } }),
    () => setAsking(true),
  );

  const failure = activityState.isError ? activityState.error : viceState.isError && !asking ? viceState.error : undefined;

  return (
    <div className="eyv-actions">
      <div className="eyv-actions__grid">
        <button type="button" className="eyv-action eyv-action--vice" aria-label={`Log ${emoji}`} {...press}>
          <span className="eyv-action__icon" aria-hidden="true">{emoji}</span>
          <span className="eyv-action__inc">+1 {emoji}</span>
          <span className="eyv-action__total">{formatAmount(t.vice)} <small>TOTAL</small></span>
        </button>
        {ACTIVITIES.map(({ type, icon, increment }) => (
          <button
            key={type}
            type="button"
            className="eyv-action"
            onClick={() => void logActivity({ activityRequest: { type, amount: 1 } })}
          >
            <span className="eyv-action__points">{formatPoints(dashboard.pointsPerUnit[type] ?? 0)}</span>
            <span className="eyv-action__icon" aria-hidden="true">{icon}</span>
            <span className="eyv-action__inc">{type} {increment}</span>
            <span className="eyv-action__total">{t[type] > 0 ? formatAmount(t[type]) : '-'}</span>
          </button>
        ))}
      </div>
      <p className="eyv-hint">Hold {emoji} to log a custom amount.</p>
      {failure !== undefined && <p className="eyv-error" role="alert">{errorMessage(failure)}</p>}
      {asking && (
        <AmountDialog
          title={`Custom ${emoji} entry`}
          allowZero={false}
          confirmLabel="Log"
          busy={viceState.isLoading}
          error={viceState.isError ? errorMessage(viceState.error) : undefined}
          onClose={() => { setAsking(false); viceState.reset(); }}
          onConfirm={(amount) => void logVice({ amountRequest: { amount } }).unwrap().then(() => setAsking(false), () => undefined)}
        />
      )}
    </div>
  );
}
