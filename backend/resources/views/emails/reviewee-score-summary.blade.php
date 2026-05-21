<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CFAS Score Summary</title>
</head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;color:#111827;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f3f4f6;padding:28px 12px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:720px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e5e7eb;">
                    <tr>
                        <td style="padding:28px 32px;background:#111827;color:#ffffff;">
                            <div style="font-size:13px;letter-spacing:.08em;text-transform:uppercase;color:#d1d5db;">CFAS Review Hub</div>
                            <h1 style="margin:8px 0 4px;font-size:26px;line-height:1.2;">Score Summary</h1>
                            <div style="font-size:14px;color:#d1d5db;">Generated {{ $summary['generated_at'] }}</div>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:26px 32px;">
                            <h2 style="margin:0 0 4px;font-size:20px;color:#111827;">{{ $summary['student']['name'] }}</h2>
                            <div style="font-size:14px;color:#6b7280;">@{{ $summary['student']['username'] }}</div>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:24px;">
                                <tr>
                                    <td style="padding:16px;background:#f9fafb;border-radius:12px;">
                                        <div style="font-size:12px;color:#6b7280;text-transform:uppercase;letter-spacing:.04em;">Pass Rate</div>
                                        <div style="font-size:30px;font-weight:700;color:#111827;margin-top:4px;">{{ number_format($summary['overall']['pass_rate'], 2) }}%</div>
                                    </td>
                                    <td width="12"></td>
                                    <td style="padding:16px;background:#f9fafb;border-radius:12px;">
                                        <div style="font-size:12px;color:#6b7280;text-transform:uppercase;letter-spacing:.04em;">Average Score</div>
                                        <div style="font-size:30px;font-weight:700;color:#111827;margin-top:4px;">{{ number_format($summary['overall']['average_percentage'], 2) }}%</div>
                                    </td>
                                </tr>
                            </table>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:12px;">
                                <tr>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;">
                                        <div style="font-size:20px;font-weight:700;">{{ $summary['overall']['exams_taken'] }}</div>
                                        <div style="font-size:12px;color:#6b7280;">Exams Taken</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;">
                                        <div style="font-size:20px;font-weight:700;color:#16a34a;">{{ $summary['overall']['passed'] }}</div>
                                        <div style="font-size:12px;color:#6b7280;">Passed</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;">
                                        <div style="font-size:20px;font-weight:700;color:#dc2626;">{{ $summary['overall']['failed'] }}</div>
                                        <div style="font-size:12px;color:#6b7280;">Failed</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;">
                                        <div style="font-size:20px;font-weight:700;">{{ $summary['overall']['attempts_count'] }}</div>
                                        <div style="font-size:12px;color:#6b7280;">Attempts</div>
                                    </td>
                                </tr>
                            </table>

                            <h3 style="font-size:16px;margin:28px 0 12px;color:#111827;">Category Breakdown</h3>
                            @foreach ($summary['categories'] as $category)
                                <div style="border:1px solid #e5e7eb;border-radius:12px;margin-bottom:14px;overflow:hidden;">
                                    <div style="padding:14px 16px;background:#f9fafb;border-bottom:1px solid #e5e7eb;">
                                        <strong style="font-size:15px;color:#111827;">{{ $category['category'] }}</strong>
                                        <span style="float:right;font-size:13px;color:#6b7280;">{{ $category['status'] }}</span>
                                    </div>
                                    <div style="padding:14px 16px;">
                                        <div style="font-size:13px;color:#6b7280;margin-bottom:10px;">
                                            Average {{ number_format($category['average_percentage'], 2) }}% | Passed {{ $category['passed'] }} of {{ $category['exams_taken'] }}
                                        </div>
                                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                            @foreach ($category['exams'] as $exam)
                                                <tr>
                                                    <td style="padding:8px 0;border-top:1px solid #f3f4f6;font-size:13px;color:#111827;">
                                                        {{ $exam['title'] }}
                                                    </td>
                                                    <td align="right" style="padding:8px 0;border-top:1px solid #f3f4f6;font-size:13px;color:#111827;">
                                                        {{ $exam['best_score'] }}/{{ $exam['total_questions'] }} ({{ number_format($exam['best_percentage'], 2) }}%)
                                                    </td>
                                                    <td align="right" style="padding:8px 0;border-top:1px solid #f3f4f6;font-size:12px;font-weight:700;color:{{ $exam['status'] === 'Passed' ? '#16a34a' : '#dc2626' }};">
                                                        {{ $exam['status'] }}
                                                    </td>
                                                </tr>
                                            @endforeach
                                        </table>
                                    </div>
                                </div>
                            @endforeach

                            <p style="margin:24px 0 0;font-size:12px;line-height:1.6;color:#6b7280;">
                                This summary includes completed and auto-submitted attempts from exams that are still available in the system.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
