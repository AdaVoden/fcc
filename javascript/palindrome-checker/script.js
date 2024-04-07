const inputText = document.getElementById("text-input");
const checkButton = document.getElementById("check-btn");
const resultText = document.getElementById("result");

function isPalindrome(string) {
  if (string.length === 1) {
    // Technically a zero or 1 length string is a palindrome.
    return true;
  }
  const cleanedText = sanitizeText(string);
  // split into an array and check if same backward and forward
  // not the best solution though.
  const reversedText = cleanedText.split("").toReversed().join("");
  return cleanedText === reversedText;
}

function addResult(string, truthiness) {
  resultText.innerText = "";
  // Extra space in 'not' for potential failure of thing
  const notOrBlank = truthiness ? "" : "not ";
  resultText.innerHTML = `<p><strong>${string}</strong> is ${notOrBlank}a palindrome</p>`;
  resultText.classList.remove("hide");
}

function errorResult() {
  resultText.innerText = "";
  resultText.classList.add("hide");
  alert("Please input a value.");
}

function sanitizeText(string) {
  // Regex matches all non-alphanumeric characters
  // globally, ignoring case
  const notAlphanumericRegex = /[^a-z0-9]/gi;
  let cleanText = string.replaceAll(notAlphanumericRegex, "").toLowerCase();
  return cleanText;
}

function checkClicked() {
  // Get value, check if it's a palindrome and give to result
  const text = inputText.value;
  if (text.length === 0) {
    errorResult();
  } else {
    addResult(text, isPalindrome(text));
  }
}

checkButton.addEventListener("click", checkClicked);
