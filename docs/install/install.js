document.querySelectorAll('button[data-copy]').forEach((button) => {
  button.addEventListener('click', async () => {
    const input = document.getElementById(button.dataset.copy);
    const status = document.getElementById(button.dataset.status);
    try {
      if (!window.isSecureContext || !navigator.clipboard?.writeText) {
        throw new Error('Clipboard unavailable');
      }
      await navigator.clipboard.writeText(input.value);
      status.textContent = '已复制，返回小火箭粘贴 URL 即可。';
    } catch {
      input.focus();
      input.select();
      input.setSelectionRange(0, input.value.length);
      status.textContent = '请长按已选中的 URL，选择“复制”，再返回小火箭粘贴。';
    }
  });
});
