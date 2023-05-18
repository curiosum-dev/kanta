export const Select = {
  mounted() {
    this.el.addEventListener("selected-change", (event) => {
      this.pushEventTo(event.detail.id, "update", event.detail);
    });

    this.handleEvent("close-selected", (data) => {
      const fieldId = data.id;
      const element = document.querySelector(fieldId);

      element.value = data.value;
      element.dispatchEvent(new Event("input", { bubbles: true }));

      if (!element) return;
      if (data.id !== `#${this.el.id}`) return;

      element.dispatchEvent(new CustomEvent("reset"));
    });
  },
};
