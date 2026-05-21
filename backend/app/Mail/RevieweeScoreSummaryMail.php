<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class RevieweeScoreSummaryMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public array $summary,
        public ?string $spreadsheetBinary = null,
        public ?string $spreadsheetFilename = null
    )
    {
    }

    public function build(): self
    {
        $mail = $this
            ->subject('CFAS Review Hub | Score Summary for ' . $this->summary['student']['name'])
            ->view('emails.reviewee-score-summary')
            ->with([
                'summary' => $this->summary,
                'spreadsheetFilename' => $this->spreadsheetFilename,
            ]);

        if ($this->spreadsheetBinary && $this->spreadsheetFilename) {
            $mail->attachData($this->spreadsheetBinary, $this->spreadsheetFilename, [
                'mime' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ]);
        }

        return $mail;
    }
}
