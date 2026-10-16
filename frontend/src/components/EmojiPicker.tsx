import { Input } from './ui';

export const DEFAULT_VICE = '🍕';
const QUICK_PICKS = ['🍕', '🎮', '🍩', '🥤', '🍫', '☕', '🍰', '🍟'];

interface EmojiPickerProps {
  value: string;
  onChange: (emoji: string) => void;
  error?: string;
  label?: string;
}

/** A free emoji field (plain keyboard characters are dropped, as in the Flutter app) plus quick picks. */
export default function EmojiPicker({ value, onChange, error, label = 'Vice emoji' }: EmojiPickerProps) {
  return (
    <div className="eyv-emoji">
      <Input
        label={label}
        className="eyv-emoji__field"
        value={value}
        // eslint-disable-next-line no-control-regex
        onChange={(e) => onChange(e.target.value.replace(/[\x00-\x7F]/g, ''))}
        placeholder={DEFAULT_VICE}
        error={error}
        autoComplete="off"
      />
      <div className="eyv-emoji__picks" role="group" aria-label="Quick picks">
        {QUICK_PICKS.map((e) => (
          <button
            key={e}
            type="button"
            className={`eyv-pick${value === e ? ' eyv-pick--on' : ''}`}
            aria-label={`Pick ${e}`}
            aria-pressed={value === e}
            onClick={() => onChange(e)}
          >{e}</button>
        ))}
      </div>
    </div>
  );
}
