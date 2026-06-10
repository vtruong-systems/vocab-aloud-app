String normalizeAnswer(String input) => input.trim().toLowerCase();

bool answersMatch(String input, String target) {
  return normalizeAnswer(input) == normalizeAnswer(target);
}
