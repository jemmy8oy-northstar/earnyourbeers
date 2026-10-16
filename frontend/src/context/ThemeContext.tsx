import React, { useEffect, useState } from 'react';
import { ThemeContext, type Theme, type ThemeMode } from './theme-context';

const QUERY = '(prefers-color-scheme: dark)';

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [mode, setMode] = useState<ThemeMode>(() => {
        const saved = localStorage.getItem('theme');
        return saved === 'auto' || saved === 'light' || saved === 'dark' ? saved : 'dark';
    });
    const [deviceDark, setDeviceDark] = useState(() => window.matchMedia(QUERY).matches);

    useEffect(() => {
        const query = window.matchMedia(QUERY);
        const onChange = (e: MediaQueryListEvent) => setDeviceDark(e.matches);
        query.addEventListener('change', onChange);
        return () => query.removeEventListener('change', onChange);
    }, []);

    const theme: Theme = mode === 'auto' ? (deviceDark ? 'dark' : 'light') : mode;

    useEffect(() => {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', mode);
    }, [theme, mode]);

    const toggleTheme = () => setMode(theme === 'light' ? 'dark' : 'light');

    return (
        <ThemeContext.Provider value={{ theme, mode, setMode, toggleTheme }}>
            {children}
        </ThemeContext.Provider>
    );
};
