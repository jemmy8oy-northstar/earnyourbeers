import { Button } from './ui';
import Modal from './Modal';
import { errorMessage, useDismissSettlementMutation, type Settlement, type SettlementOutcome } from '../api/eyv';

const OUTCOME: Record<SettlementOutcome, { headline: string; tone: 'up' | 'down' | 'flat' }> = {
  Promoted: { headline: 'PROMOTED!', tone: 'up' },
  DoublePromotion: { headline: 'DOUBLE PROMOTION!', tone: 'up' },
  Demoted: { headline: 'DEMOTED', tone: 'down' },
  PositionSecured: { headline: 'POSITION SECURED', tone: 'flat' },
};

/**
 * BEH-SETTLE-2: the weekly report. Not dismissible except by "Start new week", which tells the
 * API; the dashboard refetch then comes back with no settlement and the modal goes.
 */
export default function SettlementModal({ settlement }: { settlement: Settlement }) {
  const [dismiss, { isLoading, isError, error }] = useDismissSettlementMutation();
  const { headline, tone } = OUTCOME[settlement.outcome] ?? OUTCOME.PositionSecured;
  const net = settlement.weeklyNet;

  return (
    <Modal title="Weekly settlement">
      <div className="eyv-settlement">
        <h2 className="eyv-settlement__title">WEEKLY SETTLEMENT</h2>
        <p className={`eyv-settlement__net eyv-settlement__net--${net >= 0 ? 'up' : 'down'}`}>
          {net > 0 ? '+' : ''}{net.toFixed(1)} pts
        </p>
        <p className="eyv-muted">Net effort from last week</p>
        <p className={`eyv-settlement__outcome eyv-settlement__outcome--${tone}`}>{headline}</p>
        {isError && <p className="eyv-error" role="alert">{errorMessage(error)}</p>}
        <Button size="lg" loading={isLoading} onClick={() => void dismiss()}>Start new week</Button>
      </div>
    </Modal>
  );
}
