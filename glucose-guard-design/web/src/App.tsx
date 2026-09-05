import { useEffect, useState } from "react";
import { Route, Routes } from "react-router-dom";
import { AppShell } from "./components/AppShell";
import { HomePage } from "./pages/HomePage";
import { PlaceholderPage } from "./pages/PlaceholderPage";
import { applyTheme, persistTheme, readStoredTheme, type ThemeName } from "./theme";

export default function App() {
  const [theme, setTheme] = useState<ThemeName>("dark");

  useEffect(() => {
    const initial = readStoredTheme();
    setTheme(initial);
    applyTheme(initial);
  }, []);

  function toggleTheme() {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    applyTheme(next);
    persistTheme(next);
  }

  return (
    <Routes>
      <Route
        element={
          <AppShell
            theme={theme}
            status="connected"
            onToggleTheme={toggleTheme}
          />
        }
      >
        <Route index element={<HomePage />} />
        <Route
          path="today"
          element={
            <PlaceholderPage
              title="Today"
              summary="Home timeline for glucose, insulin, and movement will land here after device APIs are wired."
            />
          }
        />
        <Route
          path="learning"
          element={
            <PlaceholderPage
              title="Learning"
              summary="AI/ML insights stay empty until a later step. The menu is in place so the OneDrop-style layout can be reviewed."
            />
          }
        />
        <Route
          path="healthway"
          element={
            <PlaceholderPage
              title="Healthway"
              summary="A later health overview (sleep, weight, heart rate) will connect here. No Withings import in step 1."
            />
          }
        />
        <Route
          path="add"
          element={
            <PlaceholderPage
              title="Add"
              summary="The + action will add bolus, glucose, or food entries. Food overview is owned by another team."
            />
          }
        />
        <Route
          path="profile"
          element={
            <PlaceholderPage
              title="Profile"
              summary="Account, A1C label, and clinician sharing requests will live here. Registration is not enabled yet."
            />
          }
        />
      </Route>
    </Routes>
  );
}
