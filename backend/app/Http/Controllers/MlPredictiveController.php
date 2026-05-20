<?php

namespace App\Http\Controllers;

use App\Services\MlPredictiveService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MlPredictiveController extends Controller
{
    private MlPredictiveService $mlPredictiveService;

    public function __construct()
    {
        $this->mlPredictiveService = new MlPredictiveService();
    }

    public function getPredictions(Request $request): JsonResponse
    {
        try {
            $timeFilter = (string)$request->input('timeFilter', 'all');
            $validTimeFilters = ['7days', '30days', '3months', 'all'];
            if (!in_array($timeFilter, $validTimeFilters, true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }

            $model = (string)$request->input('model', 'random_forest');
            $validModels = ['logistic_regression', 'random_forest', 'ensemble'];
            if (!in_array($model, $validModels, true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid model. Valid values: logistic_regression, random_forest, ensemble'
                ], 400);
            }

            $data = $this->mlPredictiveService->runPrediction($timeFilter, $model);

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
        } catch (\Throwable $error) {
            Log::error('ML predictions request failed', [
                'error' => $error->getMessage(),
                'trace' => $error->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to run ML predictions',
                'error' => $error->getMessage()
            ], 500);
        }
    }
}
