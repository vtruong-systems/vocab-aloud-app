#!/usr/bin/env python3
"""Refresh Level 1 Pre-K vocabulary per level_1_vocabulary_refresh plan."""

import csv
from collections import defaultdict

CSV_PATH = 'vocab.csv'

DEMOTE_TO_K = {
    'Red', 'Blue', 'Green', 'Yellow', 'Orange',
    'Big', 'Small', 'Square', 'Triangle', 'Shape', 'Same', 'More', 'Many', 'All',
    'First', 'Last', 'Next', 'Again',
    'Walk', 'Sit', 'Stand', 'Hop', 'Jump', 'Clap', 'Wave',
}

PROMOTE_TO_PREK = {
    'Upset', 'Discuss', 'Brave', 'Worried', 'Frustrated', 'Embarrassed',
    'Disappointed', 'Proud', 'Question', 'Explain', 'Focus', 'Listen Carefully',
    'Solve', 'Check',
}

NEW_PREK_WORDS = [
    ('Empathy', 'Feelings & Emotions', 'Understanding how someone else feels', 'caring compassion', 'hard'),
    ('Guilty', 'Feelings & Emotions', 'Feeling bad because you did something wrong', 'sorry ashamed', 'hard'),
    ('Honest', 'Feelings & Emotions', 'Telling the truth and being fair', 'truthful sincere', 'hard'),
    ('Trust', 'Feelings & Emotions', 'Believing someone will do what they say', 'faith rely', 'hard'),
    ('Attentive', 'Instructional Language', 'Paying close attention to what is happening', 'focused alert', 'medium'),
    ('Confirm', 'Communication & Discussion', 'Making sure something is true or correct', 'verify check', 'hard'),
    ('Coordinate', 'Instructional Language', 'Working together so actions fit together', 'organize plan', 'hard'),
    ('Search', 'Learning & Research', 'Looking carefully to find something', 'seek find', 'medium'),
    ('Test', 'Learning & Research', 'Trying something to see if it works', 'try experiment', 'medium'),
    ('Leap', 'Instructional Language', 'Jumping a long way forward or upward', 'jump bound', 'easy'),
    ('Investigate', 'Learning & Research', 'Looking carefully to find out more about something', 'explore examine', 'hard'),
]

PREK_SETS = {
    18: ['Happy', 'Sad', 'Angry', 'Scared', 'Upset', 'Afraid', 'Tired', 'Come'],
    19: ['Worried', 'Frustrated', 'Embarrassed', 'Disappointed', 'Proud', 'Silly', 'Grumpy', 'Sing'],
    20: ['Kind', 'Gentle', 'Honest', 'Trust', 'Empathy', 'Guilty', 'Love', 'Brave'],
    21: ['Please', 'Thank', 'Sorry', 'Excuse Me', 'Goodbye', 'Share', 'Help', 'Dance'],
    22: ['Say', 'Talk', 'Listen', 'Discuss', 'Confirm', 'Quiet', 'Wait', 'Stay'],
    23: ['Attentive', 'Follow', 'Look', 'Point', 'Focus', 'Listen Carefully', 'Stop'],
    24: ['Line Up', 'Take Turns', 'Circle Time', 'Together', 'Hands To Yourself', 'Clean Up', 'Move', 'Turn'],
    25: ['Wash Hands', 'Cover', 'Safe', 'Hurt', 'Sick', 'Hungry', 'Thirsty'],
    26: ['Touch', 'Hold', 'Push', 'Pull', 'Find', 'Show', 'Hide', 'Open'],
    27: ['Play', 'Try', 'Make', 'Search', 'Test', 'Roll', 'Stretch', 'Leap'],
    28: ['Classroom', 'Teacher', 'Rules', 'Friend', 'Lunch', 'Snack', 'Nap', 'Playground'],
    29: ['Crayon', 'Chair', 'Picture', 'Put Away', 'Pick Up', 'Put Down', 'Close'],
    30: ['Question', 'Explain', 'Investigate', 'Coordinate', 'Ready', 'Done', 'Start', 'Finish'],
    31: ['Stack', 'Drop', 'Lift', 'Glad', 'Mad', 'Rest', 'Solve', 'Check'],
}

K_SET_START = 32
K_SET_COUNT = 13  # sets 32-44; set 5 remains visible at Level 2

DIFFICULTY_OVERRIDES = {
    w: d for w, _, _, _, d in NEW_PREK_WORDS
}
DIFFICULTY_OVERRIDES.update({
    'Happy': 'easy', 'Sad': 'easy', 'Angry': 'easy', 'Listen': 'easy', 'Help': 'easy',
    'Stop': 'easy', 'Friend': 'easy', 'Play': 'easy', 'Run': 'easy', 'Red': 'easy',
    'Blue': 'easy', 'Big': 'easy', 'Small': 'easy', 'Walk': 'easy', 'Jump': 'easy',
    'Upset': 'medium', 'Worried': 'medium', 'Share': 'medium', 'Discuss': 'medium',
    'Search': 'medium', 'Brave': 'medium', 'Attentive': 'medium', 'Test': 'medium',
    'Empathy': 'hard', 'Trust': 'hard', 'Guilty': 'hard', 'Honest': 'hard',
    'Investigate': 'hard', 'Coordinate': 'hard', 'Confirm': 'hard', 'Explain': 'medium',
    'Question': 'medium', 'Frustrated': 'medium', 'Embarrassed': 'medium',
    'Disappointed': 'medium', 'Proud': 'medium',
})

HARD_CATEGORIES = {'Thinking & Reasoning', 'Scientific Thinking'}
MEDIUM_GRADES = {'2', '3'}


def pack_k_words(words: list[str]) -> dict[str, int]:
    """Assign K words evenly across sets 32-44."""
    words = sorted(set(words))
    base, extra = divmod(len(words), K_SET_COUNT)
    assignment = {}
    idx = 0
    for i in range(K_SET_COUNT):
        size = base + (1 if i < extra else 0)
        set_num = K_SET_START + i
        for word in words[idx : idx + size]:
            assignment[word] = set_num
        idx += size
    return assignment


def infer_difficulty(row: dict) -> str:
    word = row['Word']
    if word in DIFFICULTY_OVERRIDES:
        return DIFFICULTY_OVERRIDES[word]
    grade = row['Grade']
    category = row['Category']
    if grade in ('4', '5'):
        return 'hard'
    if grade == '3' or category in HARD_CATEGORIES:
        return 'hard' if grade in ('3', '4', '5') else 'medium'
    if grade in MEDIUM_GRADES or category in {
        'Feelings & Emotions', 'Communication & Discussion',
        'Learning & Research', 'Progress & Learning',
    }:
        return 'medium'
    return 'easy'


def main():
    with open(CSV_PATH, newline='') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    prek_map = {w: s for s, words in PREK_SETS.items() for w in words}

    all_prek = [w for words in PREK_SETS.values() for w in words]
    assert len(all_prek) == len(set(all_prek)) == 109, f'Pre-K sets: {len(all_prek)}'

    updated = []

    for row in rows:
        word = row['Word']
        new_row = {
            'Word': word,
            'Category': row['Category'],
            'Meaning': row['Meaning'],
            'Related Words': row['Related Words'],
            'Grade': row['Grade'],
            'Set': row['Set'],
        }

        if word in DEMOTE_TO_K and new_row['Grade'] == 'Pre-K':
            new_row['Grade'] = 'K'

        if word in PROMOTE_TO_PREK:
            new_row['Grade'] = 'Pre-K'

        if new_row['Grade'] == 'Pre-K' and word in prek_map:
            new_row['Set'] = str(prek_map[word])

        new_row['Difficulty'] = infer_difficulty(new_row)
        updated.append(new_row)

    for word, category, meaning, related, difficulty in NEW_PREK_WORDS:
        set_num = prek_map[word]
        updated.append({
            'Word': word,
            'Category': category,
            'Meaning': meaning,
            'Related Words': related,
            'Grade': 'Pre-K',
            'Difficulty': difficulty,
            'Set': str(set_num),
        })

    k_words = []
    for row in updated:
        if row['Grade'] == 'K':
            k_words.append(row['Word'])
    k_map = pack_k_words(k_words)
    for row in updated:
        if row['Grade'] == 'K':
            row['Set'] = str(k_map[row['Word']])

    fieldnames = ['Word', 'Category', 'Meaning', 'Related Words', 'Grade', 'Difficulty', 'Set']
    with open(CSV_PATH, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(updated)

    prek = [r for r in updated if r['Grade'] == 'Pre-K']
    k32_44 = [r for r in updated if r['Grade'] == 'K' and 32 <= int(r['Set']) <= 44]
    colors = [r['Word'] for r in prek if r['Word'] in DEMOTE_TO_K]

    print(f'Total rows: {len(updated)}')
    print(f'Pre-K: {len(prek)} (expect 109)')
    print(f'K sets 32-44: {len(k32_44)}')
    print(f'Colors in Pre-K: {colors} (expect [])')
    print(f'Sets used: {sorted(set(int(r["Set"]) for r in updated))}')


if __name__ == '__main__':
    main()
