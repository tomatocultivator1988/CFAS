@php
    $average = (float) $summary['overall']['average_percentage'];
    $overallLabel = $average >= 90 ? 'Excellent' : ($average >= 75 ? 'Good Standing' : 'Needs Review');
    $overallColor = $average >= 90 ? '#166534' : ($average >= 75 ? '#92400e' : '#991b1b');
    $overallBg = $average >= 90 ? '#dcfce7' : ($average >= 75 ? '#fef3c7' : '#fee2e2');
@endphp
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CFAS Score Summary</title>
</head>
<body style="margin:0;padding:0;background:#eef2f7;font-family:Arial,Helvetica,sans-serif;color:#111827;">
    <div style="display:none;max-height:0;overflow:hidden;color:transparent;">
        Your CFAS score summary is ready. The detailed XLSX report is attached.
    </div>

    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#eef2f7;padding:32px 12px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:760px;background:#ffffff;border:1px solid #dbe3ee;border-radius:12px;overflow:hidden;">
                    <tr>
                        <td style="padding:26px 32px;background:#0f172a;color:#ffffff;">
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <div style="font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:#cbd5e1;font-weight:700;">CFAS Review Hub</div>
                                        <h1 style="margin:10px 0 6px;font-size:26px;line-height:1.25;font-weight:700;">Score Summary Report</h1>
                                        <div style="font-size:14px;color:#cbd5e1;">Generated {{ $summary['generated_at'] }}</div>
                                    </td>
                                    <td align="right" style="vertical-align:top;">
                                        <span style="display:inline-block;padding:8px 12px;border-radius:999px;background:{{ $overallBg }};color:{{ $overallColor }};font-size:12px;font-weight:700;">
                                            {{ $overallLabel }}
                                        </span>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:28px 32px 8px;">
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td style="vertical-align:top;">
                                        <div style="font-size:13px;color:#64748b;font-weight:700;text-transform:uppercase;">Reviewee</div>
                                        <h2 style="margin:6px 0 4px;font-size:22px;line-height:1.25;color:#0f172a;">{{ $summary['student']['name'] }}</h2>
                                        <div style="font-size:14px;color:#64748b;">{{ '@' . $summary['student']['username'] }} | {{ $summary['student']['email'] }}</div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:18px 32px;">
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td style="padding:18px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                                        <div style="font-size:12px;color:#64748b;text-transform:uppercase;font-weight:700;">Average Score</div>
                                        <div style="margin-top:6px;font-size:32px;line-height:1;font-weight:700;color:#0f172a;">{{ number_format($summary['overall']['average_percentage'], 2) }}%</div>
                                    </td>
                                    <td width="12"></td>
                                    <td style="padding:18px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                                        <div style="font-size:12px;color:#64748b;text-transform:uppercase;font-weight:700;">Pass Rate</div>
                                        <div style="margin-top:6px;font-size:32px;line-height:1;font-weight:700;color:#0f172a;">{{ number_format($summary['overall']['pass_rate'], 2) }}%</div>
                                    </td>
                                </tr>
                            </table>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:12px;">
                                <tr>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e2e8f0;border-radius:8px;">
                                        <div style="font-size:20px;font-weight:700;color:#0f172a;">{{ $summary['overall']['exams_taken'] }}</div>
                                        <div style="font-size:12px;color:#64748b;">Exams Taken</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e2e8f0;border-radius:8px;">
                                        <div style="font-size:20px;font-weight:700;color:#166534;">{{ $summary['overall']['passed'] }}</div>
                                        <div style="font-size:12px;color:#64748b;">Passed</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e2e8f0;border-radius:8px;">
                                        <div style="font-size:20px;font-weight:700;color:#991b1b;">{{ $summary['overall']['failed'] }}</div>
                                        <div style="font-size:12px;color:#64748b;">Failed</div>
                                    </td>
                                    <td width="10"></td>
                                    <td style="padding:14px;background:#ffffff;border:1px solid #e2e8f0;border-radius:8px;">
                                        <div style="font-size:20px;font-weight:700;color:#0f172a;">{{ $summary['overall']['attempts_count'] }}</div>
                                        <div style="font-size:12px;color:#64748b;">Attempts</div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    @if ($spreadsheetFilename)
                        <tr>
                            <td style="padding:0 32px 20px;">
                                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px;">
                                    <tr>
                                        <td style="padding:16px 18px;">
                                            <div style="font-size:14px;font-weight:700;color:#1e3a8a;">Detailed XLSX report attached</div>
                                            <div style="margin-top:4px;font-size:13px;color:#1e40af;line-height:1.5;">
                                                Download <strong>{{ $spreadsheetFilename }}</strong> from this email to review the category summary and detailed exam results in spreadsheet format.
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    @endif

                    <tr>
                        <td style="padding:4px 32px 26px;">
                            <h3 style="margin:0 0 12px;font-size:16px;color:#0f172a;">Category Overview</h3>

                            @foreach ($summary['categories'] as $category)
                                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-bottom:12px;border:1px solid #e2e8f0;border-radius:10px;overflow:hidden;">
                                    <tr>
                                        <td style="padding:14px 16px;background:#f8fafc;border-bottom:1px solid #e2e8f0;">
                                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td style="font-size:15px;font-weight:700;color:#0f172a;">{{ $category['category'] }}</td>
                                                    <td align="right" style="font-size:13px;font-weight:700;color:#475569;">{{ $category['status'] }}</td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding:14px 16px;">
                                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td style="font-size:13px;color:#64748b;">
                                                        Average <strong style="color:#0f172a;">{{ number_format($category['average_percentage'], 2) }}%</strong>
                                                    </td>
                                                    <td align="right" style="font-size:13px;color:#64748b;">
                                                        Passed <strong style="color:#0f172a;">{{ $category['passed'] }}</strong> of <strong style="color:#0f172a;">{{ $category['exams_taken'] }}</strong>
                                                    </td>
                                                </tr>
                                            </table>

                                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:10px;">
                                                @foreach ($category['exams'] as $exam)
                                                    <tr>
                                                        <td style="padding:9px 0;border-top:1px solid #f1f5f9;font-size:13px;color:#0f172a;">
                                                            {{ $exam['title'] }}
                                                        </td>
                                                        <td align="right" style="padding:9px 10px;border-top:1px solid #f1f5f9;font-size:13px;color:#334155;white-space:nowrap;">
                                                            {{ $exam['best_score'] }}/{{ $exam['total_questions'] }} ({{ number_format($exam['best_percentage'], 2) }}%)
                                                        </td>
                                                        <td align="right" style="padding:9px 0;border-top:1px solid #f1f5f9;font-size:12px;font-weight:700;color:{{ $exam['status'] === 'Passed' ? '#166534' : '#991b1b' }};white-space:nowrap;">
                                                            {{ $exam['status'] }}
                                                        </td>
                                                    </tr>
                                                @endforeach
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            @endforeach

                            <p style="margin:18px 0 0;font-size:12px;line-height:1.6;color:#64748b;">
                                This report includes completed and auto-submitted attempts from exams that are still available in the system.
                            </p>
                        </td>
                    </tr>
                </table>

                <div style="max-width:760px;margin:14px auto 0;text-align:center;font-size:12px;color:#64748b;line-height:1.5;">
                    CFAS Review Hub automated score notification
                </div>
            </td>
        </tr>
    </table>
</body>
</html>
