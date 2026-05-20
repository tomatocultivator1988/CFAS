<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\RandomizationService;
use Illuminate\Support\Collection;

class RandomizationServiceTest extends TestCase
{
    protected RandomizationService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new RandomizationService();
    }

    /** @test */
    public function it_generates_unique_seeds_for_different_attempts()
    {
        $seed1 = $this->service->generateSeed(1, 1, 1);
        $seed2 = $this->service->generateSeed(1, 1, 2);
        $seed3 = $this->service->generateSeed(1, 2, 1);
        
        $this->assertNotEquals($seed1, $seed2, 'Different attempts should have different seeds');
        $this->assertNotEquals($seed1, $seed3, 'Different reviewees should have different seeds');
        $this->assertNotEquals($seed2, $seed3, 'Different combinations should have different seeds');
    }

    /** @test */
    public function it_randomizes_questions_consistently_with_same_seed()
    {
        $questions = collect([
            (object)['id' => 1, 'question_text' => 'Q1'],
            (object)['id' => 2, 'question_text' => 'Q2'],
            (object)['id' => 3, 'question_text' => 'Q3'],
            (object)['id' => 4, 'question_text' => 'Q4'],
            (object)['id' => 5, 'question_text' => 'Q5'],
        ]);

        $seed = 'test-seed-123';
        
        $result1 = $this->service->randomizeQuestions($questions, $seed);
        $result2 = $this->service->randomizeQuestions($questions, $seed);
        
        $this->assertEquals(
            $result1->pluck('id')->toArray(),
            $result2->pluck('id')->toArray(),
            'Same seed should produce same order'
        );
    }

    /** @test */
    public function it_randomizes_questions_differently_with_different_seeds()
    {
        $questions = collect([
            (object)['id' => 1, 'question_text' => 'Q1'],
            (object)['id' => 2, 'question_text' => 'Q2'],
            (object)['id' => 3, 'question_text' => 'Q3'],
            (object)['id' => 4, 'question_text' => 'Q4'],
            (object)['id' => 5, 'question_text' => 'Q5'],
        ]);

        $seed1 = 'seed-1';
        $seed2 = 'seed-2';
        
        $result1 = $this->service->randomizeQuestions($questions, $seed1);
        $result2 = $this->service->randomizeQuestions($questions, $seed2);
        
        $this->assertNotEquals(
            $result1->pluck('id')->toArray(),
            $result2->pluck('id')->toArray(),
            'Different seeds should produce different orders'
        );
    }

    /** @test */
    public function it_randomizes_answer_choices_consistently()
    {
        $choices = collect([
            (object)['id' => 1, 'choice_text' => 'A', 'is_correct' => false],
            (object)['id' => 2, 'choice_text' => 'B', 'is_correct' => true],
            (object)['id' => 3, 'choice_text' => 'C', 'is_correct' => false],
            (object)['id' => 4, 'choice_text' => 'D', 'is_correct' => false],
        ]);

        $seed = 'test-seed-456';
        $questionId = 1;
        
        $result1 = $this->service->randomizeChoices($choices, $seed, $questionId);
        $result2 = $this->service->randomizeChoices($choices, $seed, $questionId);
        
        $this->assertEquals(
            $result1->pluck('id')->toArray(),
            $result2->pluck('id')->toArray(),
            'Same seed should produce same choice order'
        );
    }

    /** @test */
    public function it_randomizes_choices_differently_for_different_questions()
    {
        $choices = collect([
            (object)['id' => 1, 'choice_text' => 'A', 'is_correct' => false],
            (object)['id' => 2, 'choice_text' => 'B', 'is_correct' => true],
            (object)['id' => 3, 'choice_text' => 'C', 'is_correct' => false],
            (object)['id' => 4, 'choice_text' => 'D', 'is_correct' => false],
        ]);

        $seed = 'test-seed-789';
        
        $result1 = $this->service->randomizeChoices($choices, $seed, 1);
        $result2 = $this->service->randomizeChoices($choices, $seed, 2);
        
        $this->assertNotEquals(
            $result1->pluck('id')->toArray(),
            $result2->pluck('id')->toArray(),
            'Different questions should have different choice orders'
        );
    }

    /** @test */
    public function it_preserves_all_items_during_randomization()
    {
        $questions = collect([
            (object)['id' => 1, 'question_text' => 'Q1'],
            (object)['id' => 2, 'question_text' => 'Q2'],
            (object)['id' => 3, 'question_text' => 'Q3'],
        ]);

        $seed = 'test-seed';
        $result = $this->service->randomizeQuestions($questions, $seed);
        
        $this->assertEquals(3, $result->count(), 'Should preserve all items');
        $this->assertEquals(
            $questions->pluck('id')->sort()->values()->toArray(),
            $result->pluck('id')->sort()->values()->toArray(),
            'Should contain same items, just reordered'
        );
    }

    /** @test */
    public function it_verifies_consistency()
    {
        $items = collect([
            (object)['id' => 1],
            (object)['id' => 2],
            (object)['id' => 3],
        ]);

        $seed = 'consistency-test';
        
        $isConsistent = $this->service->verifyConsistency($items, $seed);
        
        $this->assertTrue($isConsistent, 'Same seed should produce consistent results');
    }

    /** @test */
    public function it_verifies_different_seeds_produce_different_results()
    {
        $items = collect([
            (object)['id' => 1],
            (object)['id' => 2],
            (object)['id' => 3],
            (object)['id' => 4],
            (object)['id' => 5],
        ]);

        $seed1 = 'seed-alpha';
        $seed2 = 'seed-beta';
        
        $isDifferent = $this->service->verifyDifferentSeeds($items, $seed1, $seed2);
        
        $this->assertTrue($isDifferent, 'Different seeds should produce different results');
    }

    /** @test */
    public function it_randomizes_exam_content_with_both_options_enabled()
    {
        $questions = collect([
            (object)[
                'id' => 1,
                'question_text' => 'Q1',
                'answerChoices' => collect([
                    (object)['id' => 1, 'choice_text' => 'A'],
                    (object)['id' => 2, 'choice_text' => 'B'],
                ])
            ],
            (object)[
                'id' => 2,
                'question_text' => 'Q2',
                'answerChoices' => collect([
                    (object)['id' => 3, 'choice_text' => 'C'],
                    (object)['id' => 4, 'choice_text' => 'D'],
                ])
            ],
        ]);

        $seed = 'full-randomization';
        
        $result = $this->service->randomizeExamContent($questions, $seed, true, true);
        
        $this->assertEquals(2, $result->count(), 'Should preserve question count');
        $this->assertNotNull($result->first()->answerChoices, 'Should preserve answer choices');
    }

    /** @test */
    public function it_skips_question_randomization_when_disabled()
    {
        $questions = collect([
            (object)['id' => 1, 'question_text' => 'Q1', 'answerChoices' => collect()],
            (object)['id' => 2, 'question_text' => 'Q2', 'answerChoices' => collect()],
            (object)['id' => 3, 'question_text' => 'Q3', 'answerChoices' => collect()],
        ]);

        $seed = 'no-question-randomization';
        
        $result = $this->service->randomizeExamContent($questions, $seed, false, false);
        
        $this->assertEquals(
            [1, 2, 3],
            $result->pluck('id')->toArray(),
            'Should preserve original order when randomization disabled'
        );
    }
}
