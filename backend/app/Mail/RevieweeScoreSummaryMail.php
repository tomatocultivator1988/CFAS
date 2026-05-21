<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class RevieweeScoreSummaryMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public array $summary)
    {
    }

    public function build(): self
    {
        return $this
            ->subject('CFAS Score Summary - ' . $this->summary['student']['name'])
            ->view('emails.reviewee-score-summary')
            ->with([
                'summary' => $this->summary,
            ]);
    }
}
