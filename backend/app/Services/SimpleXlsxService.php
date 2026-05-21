<?php

namespace App\Services;

class SimpleXlsxService
{
    public function build(array $rows, string $sheetName = 'Export'): string
    {
        $zipFile = tempnam(sys_get_temp_dir(), 'xlsx_');
        if ($zipFile === false) {
            throw new \RuntimeException('Failed to allocate temporary file for XLSX.');
        }

        $zip = new \ZipArchive();
        if ($zip->open($zipFile, \ZipArchive::OVERWRITE) !== true) {
            @unlink($zipFile);
            throw new \RuntimeException('Failed to initialize XLSX archive.');
        }

        $zip->addFromString('[Content_Types].xml', $this->getContentTypesXml());
        $zip->addFromString('_rels/.rels', $this->getRootRelsXml());
        $zip->addFromString('xl/workbook.xml', $this->getWorkbookXml($sheetName));
        $zip->addFromString('xl/_rels/workbook.xml.rels', $this->getWorkbookRelsXml());
        $zip->addFromString('xl/worksheets/sheet1.xml', $this->buildWorksheetXml($this->normalizeRows($rows)));
        $zip->close();

        $binary = file_get_contents($zipFile);
        @unlink($zipFile);

        if ($binary === false) {
            throw new \RuntimeException('Failed to read XLSX archive.');
        }

        return $binary;
    }

    public function normalizeRows(array $rows): array
    {
        if (empty($rows)) {
            return [['No records available']];
        }

        $firstRow = $rows[0];
        if (!is_array($firstRow)) {
            return [[(string) $firstRow]];
        }

        if (array_is_list($firstRow)) {
            return array_map(function ($row) {
                if (!is_array($row)) {
                    return [(string) $row];
                }

                return array_map(fn ($value) => $this->stringifyCellValue($value), $row);
            }, $rows);
        }

        $headers = array_keys($firstRow);
        $normalized = [$headers];

        foreach ($rows as $row) {
            if (!is_array($row)) {
                $normalized[] = [(string) $row];
                continue;
            }

            $normalized[] = array_map(function ($header) use ($row) {
                return $this->stringifyCellValue($row[$header] ?? '');
            }, $headers);
        }

        return $normalized;
    }

    private function stringifyCellValue(mixed $value): string
    {
        if (is_scalar($value) || $value === null) {
            return (string) ($value ?? '');
        }

        return json_encode($value) ?: '';
    }

    private function getContentTypesXml(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            . '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            . '<Default Extension="xml" ContentType="application/xml"/>'
            . '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
            . '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            . '</Types>';
    }

    private function getRootRelsXml(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            . '</Relationships>';
    }

    private function getWorkbookXml(string $sheetName): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            . '<sheets>'
            . '<sheet name="' . $this->escapeXml($this->sanitizeSheetName($sheetName)) . '" sheetId="1" r:id="rId1"/>'
            . '</sheets>'
            . '</workbook>';
    }

    private function getWorkbookRelsXml(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
            . '</Relationships>';
    }

    private function buildWorksheetXml(array $rows): string
    {
        $rowCount = max(1, count($rows));
        $maxColumns = 1;

        foreach ($rows as $row) {
            if (is_array($row)) {
                $maxColumns = max($maxColumns, count($row));
            }
        }

        $endCell = $this->columnNumberToName($maxColumns) . $rowCount;
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
            . '<dimension ref="A1:' . $endCell . '"/>'
            . '<cols><col min="1" max="' . $maxColumns . '" width="24" bestFit="1" customWidth="1"/></cols>'
            . '<sheetData>';

        foreach ($rows as $rowIndex => $row) {
            $excelRow = $rowIndex + 1;
            $cells = is_array($row) ? array_values($row) : [(string) $row];
            $xml .= '<row r="' . $excelRow . '">';

            foreach ($cells as $columnIndex => $value) {
                $cellRef = $this->columnNumberToName($columnIndex + 1) . $excelRow;
                $cellValue = $this->escapeXml((string) ($value ?? ''));
                $xml .= '<c r="' . $cellRef . '" t="inlineStr"><is><t xml:space="preserve">' . $cellValue . '</t></is></c>';
            }

            $xml .= '</row>';
        }

        return $xml . '</sheetData></worksheet>';
    }

    private function columnNumberToName(int $columnNumber): string
    {
        $name = '';

        while ($columnNumber > 0) {
            $columnNumber--;
            $name = chr(65 + ($columnNumber % 26)) . $name;
            $columnNumber = intdiv($columnNumber, 26);
        }

        return $name;
    }

    private function sanitizeSheetName(string $sheetName): string
    {
        $clean = preg_replace('/[\\\\\\/\\?\\*\\[\\]:]/', '-', $sheetName);
        $clean = trim((string) $clean);

        if ($clean === '') {
            $clean = 'Export';
        }

        return mb_substr($clean, 0, 31);
    }

    private function escapeXml(string $value): string
    {
        $clean = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', $value) ?? '';
        return htmlspecialchars($clean, ENT_QUOTES | ENT_XML1, 'UTF-8');
    }
}
