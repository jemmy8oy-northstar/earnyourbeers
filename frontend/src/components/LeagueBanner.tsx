import type { League } from '../api/eyv';

const MIN = -25;
const MAX = 25;

/** BEH-LEAGUE-1: division, tier name, tally to 2dp, on a bar from −25 to +25. */
export default function LeagueBanner({ league }: { league: League }) {
  const fill = Math.min(1, Math.max(0, league.tallyProgress));
  return (
    <section className="eyv-league" aria-label="League">
      <div className="eyv-league__row">
        <div>
          <div className="eyv-league__division">{league.division.toUpperCase()}</div>
          <div className="eyv-league__tier">{league.tier}</div>
        </div>
        <div className="eyv-league__tally">{league.tally.toFixed(2)} pts</div>
      </div>
      <div
        className="eyv-bar"
        role="progressbar"
        aria-label="League tally"
        aria-valuemin={MIN}
        aria-valuemax={MAX}
        aria-valuenow={league.tally}
      >
        <div className="eyv-bar__fill" style={{ width: `${fill * 100}%` }} />
      </div>
      <div className="eyv-bar__scale" aria-hidden="true"><span>{MIN}</span><span>+{MAX}</span></div>
    </section>
  );
}
