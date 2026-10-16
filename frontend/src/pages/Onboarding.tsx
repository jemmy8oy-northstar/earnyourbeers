import { useState } from 'react';
import { Button, Card, CardBody } from '../components/ui';
import EmojiPicker, { DEFAULT_VICE } from '../components/EmojiPicker';
import { errorMessage, useOnboardMutation } from '../api/eyv';

type Sport = 'Run' | 'Cycle' | 'Swim';

const SPORTS: { sport: Sport; icon: string }[] = [
  { sport: 'Run', icon: '🏃' },
  { sport: 'Cycle', icon: '🚴' },
  { sport: 'Swim', icon: '🏊' },
];

// Slider ceiling, unit and step (20 divisions, as in the Flutter app).
const VOLUME: Record<Sport, { max: number; unit: string }> = {
  Run: { max: 100, unit: 'KM' },
  Cycle: { max: 300, unit: 'KM' },
  Swim: { max: 3000, unit: 'LENGTHS' },
};

/** The effort badge, judged in running-km equivalents (cycle ÷ 3, swim ÷ 30). */
function badge(sport: Sport, volume: number): string {
  const km = sport === 'Cycle' ? volume / 3 : sport === 'Swim' ? volume / 30 : volume;
  if (km >= 80) return 'LEGENDARY';
  if (km >= 50) return 'ELITE';
  if (km >= 30) return 'ATHLETE';
  if (km >= 10) return 'CONSISTENT';
  return 'BEGINNER';
}

const STEPS = 4;

/** BEH-ONBOARD-1: four steps, then the API seeds the starting tier. */
export default function Onboarding() {
  const [step, setStep] = useState(1);
  const [sport, setSport] = useState<Sport>('Run');
  const [volume, setVolume] = useState(0);
  const [vice, setVice] = useState(DEFAULT_VICE);
  const [viceCount, setViceCount] = useState(0);
  const [onboard, { isLoading, isError, error }] = useOnboardMutation();

  const { max, unit } = VOLUME[sport];
  const last = step === STEPS;

  const chooseSport = (s: Sport) => { setSport(s); setVolume(0); };

  const enter = () =>
    void onboard({
      onboardRequest: { sport, weeklyVolume: volume, viceEmoji: vice.trim() || DEFAULT_VICE, weeklyViceCount: viceCount },
    });

  return (
    <div className="eyv-narrow">
      <Card>
        <CardBody>
          <div className="eyv-form">
            <p className="eyv-step">{step} / {STEPS}</p>

            {step === 1 && (
              <>
                <h2 className="eyv-form__heading">1. PRIMARY ENGINE</h2>
                <p className="eyv-muted">The fitness community for the rest of us. We track the work so you can enjoy the reward.</p>
                <div className="eyv-choices" role="radiogroup" aria-label="Primary engine">
                  {SPORTS.map(({ sport: s, icon }) => (
                    <button
                      key={s}
                      type="button"
                      role="radio"
                      aria-checked={sport === s}
                      className={`eyv-choice${sport === s ? ' eyv-choice--on' : ''}`}
                      onClick={() => chooseSport(s)}
                    >
                      <span aria-hidden="true" className="eyv-choice__icon">{icon}</span>
                      {s.toUpperCase()}
                    </button>
                  ))}
                </div>
              </>
            )}

            {step === 2 && (
              <>
                <h2 className="eyv-form__heading">2. {sport.toUpperCase()} VOLUME</h2>
                <p className="eyv-big">{volume} {unit}</p>
                <p className="eyv-muted eyv-center">average weekly output</p>
                <input
                  className="eyv-slider"
                  type="range"
                  aria-label="Weekly volume"
                  min={0}
                  max={max}
                  step={max / 20}
                  value={volume}
                  onChange={(e) => setVolume(Number(e.target.value))}
                />
                <span className="eyv-badge">{badge(sport, volume)}</span>
              </>
            )}

            {step === 3 && (
              <>
                <h2 className="eyv-form__heading">3. VICE SETUP</h2>
                <p className="eyv-muted">Choose your poison. What are we earning today?</p>
                <p className="eyv-big" aria-hidden="true">{vice || DEFAULT_VICE}</p>
                <EmojiPicker value={vice} onChange={setVice} />
              </>
            )}

            {step === 4 && (
              <>
                <h2 className="eyv-form__heading">4. SUSTAINABILITY AUDIT</h2>
                <p className="eyv-muted">Be honest: how many {vice || DEFAULT_VICE} do you typically have in a week?</p>
                <p className="eyv-big">{viceCount}</p>
                <p className="eyv-muted eyv-center">vices per week</p>
                <input
                  className="eyv-slider"
                  type="range"
                  aria-label="Vices per week"
                  min={0}
                  max={40}
                  step={2}
                  value={viceCount}
                  onChange={(e) => setViceCount(Number(e.target.value))}
                />
                {viceCount > 25 && (
                  <p className="eyv-warn">⚠️ HIGH VICE LOAD: WE'LL ADJUST RATIOS FOR SUSTAINABILITY</p>
                )}
                {isError && <p className="eyv-error" role="alert">{errorMessage(error)}</p>}
              </>
            )}

            <div className="eyv-row eyv-row--between">
              {step > 1 ? <Button variant="ghost" onClick={() => setStep(step - 1)}>Back</Button> : <span />}
              {last
                ? <Button size="lg" loading={isLoading} onClick={enter}>Enter the arena</Button>
                : <Button onClick={() => setStep(step + 1)}>Next</Button>}
            </div>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
