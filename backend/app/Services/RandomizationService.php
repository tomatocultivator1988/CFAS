<?php

namespace App\Services;

use Illuminate\Support\Collection;

class RandomizationService
{
    /**
     * Generate a unique seed for an exam attempt.
     *
     * @param int $examId
     * @param int $revieweeId
     * @param int $attemptNumber
     * @return string
     */
    public function generateSeed(int $examId, int $revieweeId, int $attemptNumber): string
    {
        return md5($examId . '-' . $revieweeId . '-' . $attemptNumber . '-' . microtime(true));
    }

    /**
     * Randomize questions using a seed for consistent ordering.
     *
     * @param Collection $questions
     * @param string $seed
     * @return Collection
     */
    public function randomizeQuestions(Collection $questions, string $seed): Collection
    {
        // Convert seed to numeric value for seeding
        $numericSeed = $this->seedToNumeric($seed);
        
        // Create array with questions and their original indices
        $questionsArray = $questions->values()->all();
        
        // Shuffle using seeded random
        $shuffled = $this->seededShuffle($questionsArray, $numericSeed);
        
        return collect($shuffled);
    }

    /**
     * Randomize answer choices for a question using a seed.
     *
     * @param Collection $choices
     * @param string $seed
     * @param int $questionId
     * @return Collection
     */
    public function randomizeChoices(Collection $choices, string $seed, int $questionId): Collection
    {
        // Create unique seed for this question's choices
        $choiceSeed = $this->seedToNumeric($seed . '-q' . $questionId);
        
        // Get choices as array
        $choicesArray = $choices->values()->all();
        
        // Shuffle using seeded random
        $shuffled = $this->seededShuffle($choicesArray, $choiceSeed);
        
        return collect($shuffled);
    }

    /**
     * Convert seed string to numeric value.
     *
     * @param string $seed
     * @return int
     */
    private function seedToNumeric(string $seed): int
    {
        // Use CRC32 to convert string to integer
        return crc32($seed);
    }

    /**
     * Shuffle array using seeded random number generator.
     * This ensures consistent ordering for the same seed.
     *
     * @param array $array
     * @param int $seed
     * @return array
     */
    private function seededShuffle(array $array, int $seed): array
    {
        // Seed the random number generator
        mt_srand($seed);
        
        // Fisher-Yates shuffle algorithm with seeded random
        $count = count($array);
        for ($i = $count - 1; $i > 0; $i--) {
            $j = mt_rand(0, $i);
            
            // Swap elements
            $temp = $array[$i];
            $array[$i] = $array[$j];
            $array[$j] = $temp;
        }
        
        // Reset random seed to avoid affecting other random operations
        mt_srand();
        
        return $array;
    }

    /**
     * Randomize both questions and their answer choices for an exam attempt.
     *
     * @param Collection $questions Questions with answerChoices relationship loaded
     * @param string $seed
     * @param bool $randomizeQuestions
     * @param bool $randomizeChoices
     * @return Collection
     */
    public function randomizeExamContent(
        Collection $questions,
        string $seed,
        bool $randomizeQuestions = true,
        bool $randomizeChoices = true
    ): Collection {
        // Randomize questions if enabled
        if ($randomizeQuestions) {
            $questions = $this->randomizeQuestions($questions, $seed);
        }

        // Randomize answer choices for each question if enabled
        if ($randomizeChoices) {
            $questions = $questions->map(function ($question) use ($seed) {
                if ($question->answerChoices) {
                    $question->answerChoices = $this->randomizeChoices(
                        $question->answerChoices,
                        $seed,
                        $question->id
                    );
                }
                return $question;
            });
        }

        return $questions;
    }

    /**
     * Verify that the same seed produces the same order.
     * Used for testing consistency.
     *
     * @param Collection $items
     * @param string $seed
     * @return bool
     */
    public function verifyConsistency(Collection $items, string $seed): bool
    {
        $firstShuffle = $this->randomizeQuestions($items, $seed);
        $secondShuffle = $this->randomizeQuestions($items, $seed);
        
        // Compare IDs in order
        $firstIds = $firstShuffle->pluck('id')->toArray();
        $secondIds = $secondShuffle->pluck('id')->toArray();
        
        return $firstIds === $secondIds;
    }

    /**
     * Verify that different seeds produce different orders.
     * Used for testing randomization.
     *
     * @param Collection $items
     * @param string $seed1
     * @param string $seed2
     * @return bool
     */
    public function verifyDifferentSeeds(Collection $items, string $seed1, string $seed2): bool
    {
        if (count($items) < 2) {
            return true; // Can't verify with less than 2 items
        }

        $firstShuffle = $this->randomizeQuestions($items, $seed1);
        $secondShuffle = $this->randomizeQuestions($items, $seed2);
        
        // Compare IDs in order
        $firstIds = $firstShuffle->pluck('id')->toArray();
        $secondIds = $secondShuffle->pluck('id')->toArray();
        
        // They should be different (with high probability for 3+ items)
        return $firstIds !== $secondIds;
    }
}
