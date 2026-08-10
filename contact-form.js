(() => {
  const form = document.getElementById("contact-form");
  const status = document.getElementById("form-status");

  if (!form || !status) {
    return;
  }

  const setStatus = (message, isError = false) => {
    status.textContent = message;
    status.classList.toggle("is-error", isError);
  };

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(form);
    if (formData.get("company")) {
      setStatus("Thanks. Your inquiry has been received.");
      form.reset();
      return;
    }

    const payload = {
      name: String(formData.get("name") || "").trim(),
      email: String(formData.get("email") || "").trim(),
      phone: String(formData.get("phone") || "").trim(),
      sessionType: String(formData.get("session-type") || "").trim(),
      message: String(formData.get("message") || "").trim(),
    };

    if (!payload.name || !payload.email || !payload.message) {
      setStatus("Please fill out the required fields before sending.", true);
      return;
    }

    setStatus("Sending your inquiry...");

    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      const result = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(result.message || "Something went wrong.");
      }

      form.reset();
      setStatus("Thank you. Your inquiry has been sent.");
    } catch (error) {
      setStatus(
        error instanceof Error
          ? error.message
          : "Unable to send the inquiry right now.",
        true,
      );
    }
  });
})();