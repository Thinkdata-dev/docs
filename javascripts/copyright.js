// 자동으로 copyright 년도 업데이트
document.addEventListener('DOMContentLoaded', function() {
  const copyrightElement = document.querySelector('.md-copyright');
  if (copyrightElement) {
    const currentYear = new Date().getFullYear();
    const copyrightText = copyrightElement.innerHTML;

    // "2024 thinkdata" 형식을 "2024 - 현재년도 thinkdata" 형식으로 변경
    if (currentYear > 2024) {
      copyrightElement.innerHTML = copyrightText.replace('2024 thinkdata', `2024 - ${currentYear} thinkdata`);
    }
  }
});
