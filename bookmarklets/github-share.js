javascript:(function(){
  /* 1. Extract Data */
  var url = window.location.href;
  var titleElement = document.querySelector('.markdown-title');
  var prTitle = titleElement ? titleElement.innerText.trim() : "Title Not Found";
  var output = ":review-9555: " + url + " <- " + prTitle;

  /* 2. Copy to Clipboard */
  var dummy = document.createElement("textarea");
  document.body.appendChild(dummy);
  dummy.value = output;
  dummy.select();
  document.execCommand("copy");
  document.body.removeChild(dummy);

  /* 3. Create Custom "Auto-Closing" Notification */
  var notify = document.createElement("div");
  notify.textContent = "Copied to clipboard";
  
  /* Styling the notification to look like a clean toast message */
  Object.assign(notify.style, {
    position: "fixed",
    top: "20px",
    left: "50%",
    transform: "translateX(-50%)",
    backgroundColor: "#2ea44f",
    color: "white",
    padding: "12px 24px",
    borderRadius: "6px",
    fontSize: "14px",
    fontWeight: "bold",
    zIndex: "10000",
    boxShadow: "0 4px 12px rgba(0,0,0,0.15)",
    fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif"
  });

  document.body.appendChild(notify);

  /* 4. Remove after 3 seconds */
  setTimeout(function() {
    notify.style.transition = "opacity 0.5s";
    notify.style.opacity = "0";
    setTimeout(function() { document.body.removeChild(notify); }, 500);
  }, 3000);
})();
