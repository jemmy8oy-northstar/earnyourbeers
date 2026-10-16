import { createContext, useContext } from 'react';

/** What is applied to the page. */
export type Theme = 'light' | 'dark';
/** What the user chose (BEH-THEME-1): follow the device, or pin one. */
export type ThemeMode = 'auto' | Theme;

export interface ThemeContextType {
    /** The resolved theme currently applied (auto already resolved against the device). */
    theme: Theme;
    mode: ThemeMode;
    setMode: (mode: ThemeMode) => void;
    /** Flip to the opposite of the applied theme, pinning it. */
    toggleTheme: () => void;
}

// The context object and its hook live here (not in ThemeContext.tsx) so that the
// component file exports *only* the ThemeProvider component. React Fast Refresh
// (react-refresh/only-export-components) requires a module to export components
// exclusively for HMR to work reliably.
export const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const useTheme = (): ThemeContextType => {
    const context = useContext(ThemeContext);
    if (context === undefined) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
};
