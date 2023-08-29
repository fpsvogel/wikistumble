// Switch between light and dark mode.
document.getElementById("theme-input").addEventListener("click", (event) => {
  const htmlElement = document.getElementsByTagName('html')[0]

  if (event.target.checked) {
    htmlElement.classList.add('dark');
  } else {
    htmlElement.classList.remove('dark')
  };

  // Make a POST request which saves the theme preference to the session.
  document.getElementById('submit-theme').click();
});
