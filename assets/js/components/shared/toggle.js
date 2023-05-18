export const Toggle = {
  mounted() {
    this.el.addEventListener("toggle-change", (event) => {
      const fieldId = event.detail.id;
      const element = document.querySelector(fieldId);

      element.value = event.detail.state;
      element.dispatchEvent(new Event("input", { bubbles: true }));

      this.pushEventTo(event.detail.id, "update", event.detail);
    });
  },
};
