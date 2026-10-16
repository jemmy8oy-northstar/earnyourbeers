import { useState } from 'react';
import { Button } from '../components/ui';
import ActionRow from '../components/ActionRow';
import LeagueBanner from '../components/LeagueBanner';
import LogList from '../components/LogList';
import SettingsModal from '../components/SettingsModal';
import SettlementModal from '../components/SettlementModal';
import Onboarding from './Onboarding';
import { useDashboard, useLogoutMutation } from '../api/eyv';
import { balanceLabel, formatBalance, weekHeader } from '../format';

/** BEH-BALANCE-1, BEH-LEAGUE-1, BEH-LOG-1/3, BEH-SETTLE-2, BEH-HISTORY-1 on one screen. */
export default function Dashboard({ username }: { username: string }) {
  // 0 = this week, −1 = last week … (the API's week offset).
  const [offset, setOffset] = useState(0);
  const { dashboard, isLoading, isError, refetch } = useDashboard(offset);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [logout, logoutState] = useLogoutMutation();

  const header = (
    <header className="eyv-header">
      <h1 className="eyv-header__title">Earn Your Vices</h1>
      <span className="eyv-header__user">{username}</span>
      {dashboard?.onboarded && (
        <button type="button" className="eyv-icon-btn" aria-label="Settings" onClick={() => setSettingsOpen(true)}>⚙</button>
      )}
      <Button size="sm" variant="secondary" loading={logoutState.isLoading} onClick={() => void logout()}>Sign out</Button>
    </header>
  );

  if (!dashboard) {
    return (
      <>
        {header}
        {isLoading && <p className="eyv-muted eyv-center">Loading…</p>}
        {isError && (
          <div className="eyv-center">
            <p className="eyv-error" role="alert">Could not load your dashboard.</p>
            <Button variant="secondary" onClick={() => void refetch()}>Try again</Button>
          </div>
        )}
      </>
    );
  }

  if (!dashboard.onboarded) {
    return (
      <>
        {header}
        <Onboarding />
      </>
    );
  }

  const { week } = dashboard;
  const current = week.offset === 0;

  return (
    <>
      {header}
      <LeagueBanner league={dashboard.league} />

      <nav className="eyv-weeknav" aria-label="Week">
        <Button
          variant="ghost"
          aria-label="Previous week"
          disabled={!week.hasEarlier}
          onClick={() => setOffset(week.offset - 1)}
        >‹</Button>
        <span className="eyv-weeknav__label">{weekHeader(week.offset, week.start)}</span>
        <Button
          variant="ghost"
          aria-label="Next week"
          disabled={current}
          onClick={() => setOffset(Math.min(0, week.offset + 1))}
        >›</Button>
      </nav>

      <div className="eyv-balance">
        <div className="eyv-balance__value" data-testid="balance">
          {formatBalance(week.balance)} {dashboard.viceEmoji}
        </div>
        <div className="eyv-balance__label">{balanceLabel(week.balance)}</div>
      </div>

      {current && <ActionRow dashboard={dashboard} />}
      <LogList dashboard={dashboard} />

      {settingsOpen && <SettingsModal viceEmoji={dashboard.viceEmoji} onClose={() => setSettingsOpen(false)} />}
      {dashboard.settlement && <SettlementModal settlement={dashboard.settlement} />}
    </>
  );
}
