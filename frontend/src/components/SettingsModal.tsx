import { useState } from 'react';
import { Button } from './ui';
import EmojiPicker, { DEFAULT_VICE } from './EmojiPicker';
import Modal from './Modal';
import { errorMessage, useChangeViceMutation, useResetProfileMutation } from '../api/eyv';
import { useTheme } from '../context/theme-context';
import type { ThemeMode } from '../context/theme-context';

const MODES: { mode: ThemeMode; label: string }[] = [
  { mode: 'auto', label: 'Auto' },
  { mode: 'light', label: 'Light' },
  { mode: 'dark', label: 'Dark' },
];

interface SettingsModalProps {
  viceEmoji: string;
  onClose: () => void;
}

/**
 * BEH-VICE-1 (change the emoji, Save), BEH-THEME-1 (Auto/Light/Dark, applied at once and
 * remembered on the device) and BEH-RESET-1 (one confirmation, then the profile is wiped and the
 * dashboard refetch lands on onboarding).
 */
export default function SettingsModal({ viceEmoji, onClose }: SettingsModalProps) {
  const { mode, setMode } = useTheme();
  const [emoji, setEmoji] = useState(viceEmoji);
  const [confirming, setConfirming] = useState(false);
  const [changeVice, viceState] = useChangeViceMutation();
  const [reset, resetState] = useResetProfileMutation();

  const save = (e: React.FormEvent) => {
    e.preventDefault();
    void changeVice({ viceRequest: { viceEmoji: emoji.trim() || DEFAULT_VICE } }).unwrap().then(onClose, () => undefined);
  };

  const doReset = () =>
    void reset({ resetRequest: { confirm: true } }).unwrap().then(onClose, () => undefined);

  return (
    <Modal title="Settings" onClose={onClose}>
      <form className="eyv-form" onSubmit={save} noValidate>
        <h2 className="eyv-form__heading">Edit your vice</h2>
        <EmojiPicker
          label="Pick an emoji"
          value={emoji}
          onChange={setEmoji}
          error={viceState.isError ? errorMessage(viceState.error) : undefined}
        />

        <fieldset className="eyv-fieldset">
          <legend className="eyv-legend">Appearance</legend>
          <div className="eyv-segments" role="radiogroup" aria-label="Appearance">
            {MODES.map(({ mode: m, label }) => (
              <button
                key={m}
                type="button"
                role="radio"
                aria-checked={mode === m}
                className={`eyv-segment${mode === m ? ' eyv-segment--on' : ''}`}
                onClick={() => setMode(m)}
              >{label}</button>
            ))}
          </div>
        </fieldset>

        <div className="eyv-row eyv-row--between">
          <Button type="button" variant="ghost" onClick={onClose}>Cancel</Button>
          <Button type="submit" loading={viceState.isLoading}>Save</Button>
        </div>

        <fieldset className="eyv-fieldset">
          <legend className="eyv-legend">Management</legend>
          {!confirming ? (
            <Button type="button" variant="secondary" onClick={() => setConfirming(true)}>Reset app</Button>
          ) : (
            <div className="eyv-confirm" role="alertdialog" aria-label="Confirm reset">
              <p>This deletes every log entry and takes you back to the start. It can't be undone.</p>
              {resetState.isError && <p className="eyv-error" role="alert">{errorMessage(resetState.error)}</p>}
              <div className="eyv-row">
                <Button type="button" variant="ghost" onClick={() => setConfirming(false)}>Keep my data</Button>
                <Button type="button" variant="danger" loading={resetState.isLoading} onClick={doReset}>Yes, reset everything</Button>
              </div>
            </div>
          )}
        </fieldset>
      </form>
    </Modal>
  );
}
