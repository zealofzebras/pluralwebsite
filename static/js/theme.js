(() => {
  const storageKey = "plural-theme";
  const systemTheme = matchMedia("(prefers-color-scheme: dark)");
  let theme = "system";
  try {
    const savedTheme = localStorage.getItem(storageKey);
    if (savedTheme === "light" || savedTheme === "dark") theme = savedTheme;
  } catch {}

  function applyTheme() {
    document.documentElement.dataset.theme = theme;
    const dark = theme === "dark" || (theme === "system" && systemTheme.matches);
    document.querySelector('meta[name="theme-color"]').content = dark ? "#141b18" : "#f4f7f5";
  }

  applyTheme();
  systemTheme.addEventListener("change", applyTheme);
  document.addEventListener("DOMContentLoaded", () => {
    const select = document.getElementById("theme-select");
    select.value = theme;
    select.closest("label").hidden = false;
    select.addEventListener("change", () => {
      theme = select.value;
      try {
        if (theme === "system") localStorage.removeItem(storageKey);
        else localStorage.setItem(storageKey, theme);
      } catch {}
      applyTheme();
    });
  });
})();