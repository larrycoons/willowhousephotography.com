(() => {
  const form = document.getElementById("contact-form");
  const status = document.getElementById("form-status");
  const maxAttachmentBytes = 3 * 1024 * 1024;

  if (!form || !status) {
    return;
  }

  const setStatus = (message, isError = false, isSuccess = false) => {
    status.textContent = message;
    status.classList.toggle("is-error", isError);
    status.classList.toggle("is-success", isSuccess);
  };

  const fileToBase64 = (file) =>
    new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = typeof reader.result === "string" ? reader.result : "";
        const commaIndex = result.indexOf(",");
        resolve(commaIndex >= 0 ? result.slice(commaIndex + 1) : result);
      };
      reader.onerror = () => reject(new Error("Unable to read the selected file."));
      reader.readAsDataURL(file);
    });

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(form);
    if (formData.get("company")) {
      setStatus("Thanks. Your inquiry has been received.", false, true);
      form.reset();
      return;
    }

    const payload = {
      name: String(formData.get("name") || "").trim(),
      email: String(formData.get("email") || "").trim(),
      phone: String(formData.get("phone") || "").trim(),
      sessionType: String(formData.get("session-type") || "").trim(),
      location: String(formData.get("location") || "").trim(),
      message: String(formData.get("message") || "").trim(),
    };

    const file = formData.get("reference-image");
    if (file instanceof File && file.size > 0) {
      if (!file.type.startsWith("image/")) {
        setStatus("Please attach an image file type.", true);
        return;
      }

      if (file.size > maxAttachmentBytes) {
        setStatus("Please keep attachments under 3 MB.", true);
        return;
      }

      try {
        payload.attachment = {
          filename: file.name || "reference-image",
          contentType: file.type || "application/octet-stream",
          dataBase64: await fileToBase64(file),
        };
      } catch (error) {
        setStatus(
          error instanceof Error
            ? error.message
            : "Unable to read the selected file.",
          true,
        );
        return;
      }
    }

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
      setStatus("Success! Your inquiry has been sent.", false, true);
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