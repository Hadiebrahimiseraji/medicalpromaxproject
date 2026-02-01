// medicalpromax_frontend/src/components/exam/ExamInterface.tsx
/**
 * Main exam interface component
 * Handles question display, answer submission, timer, and progress
 */

'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter, useParams } from 'next/navigation';
import ExamTimer from './ExamTimer';
import QuestionCard from './QuestionCard';
import ProgressBar from './ProgressBar';
import axios from '@/lib/api';

interface Question {
  id: number;
  order: number;
  question_text: string;
  question_html?: string;
  image_url?: string;
  options: Array<{
    id: number;
    option_number: number;
    option_text: string;
    option_html?: string;
  }>;
}

interface ExamInterfaceProps {
  attemptId: number;
  exam: {
    id: number;
    title: string;
    duration_minutes: number;
    total_questions: number;
    is_timed: boolean;
  };
  initialQuestion: Question;
}

const ExamInterface: React.FC<ExamInterfaceProps> = ({
  attemptId,
  exam,
  initialQuestion,
}) => {
  const router = useRouter();
  const [currentQuestion, setCurrentQuestion] = useState<Question>(initialQuestion);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [progress, setProgress] = useState({
    answered: 0,
    correct: 0,
    wrong: 0,
    unanswered: exam.total_questions,
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [questionStartTime, setQuestionStartTime] = useState(Date.now());

  // RTL Support
  useEffect(() => {
    document.documentElement.dir = 'rtl';
  }, []);

  const handleSubmitAnswer = useCallback(async () => {
    if (!selectedOption) return;

    setIsSubmitting(true);
    const timeSpent = Math.floor((Date.now() - questionStartTime) / 1000);

    try {
      const response = await axios.post(
        `/api/exam-attempts/${attemptId}/submit-answer/`,
        {
          question_id: currentQuestion.id,
          selected_option_id: selectedOption,
          time_spent_seconds: timeSpent,
        }
      );

      // Update progress
      setProgress(response.data.progress);

      // Move to next question if available
      if (response.data.next_question) {
        setCurrentQuestion(response.data.next_question);
        setSelectedOption(null);
        setQuestionStartTime(Date.now());
      } else {
        // All questions answered - ready to complete
        setCurrentQuestion(null);
      }
    } catch (error) {
      console.error('Error submitting answer:', error);
      alert('خطا در ثبت پاسخ. لطفا دوباره تلاش کنید');
    } finally {
      setIsSubmitting(false);
    }
  }, [selectedOption, currentQuestion, attemptId, questionStartTime]);

  const handleCompleteExam = async () => {
    if (window.confirm('آیا می‌خواهید آزمون را اتمام دهید؟')) {
      try {
        const response = await axios.post(
          `/api/exam-attempts/${attemptId}/complete/`
        );
        router.push(
          `/exam/${exam.id}/results/${response.data.attempt.id}`
        );
      } catch (error) {
        console.error('Error completing exam:', error);
        alert('خطا در اتمام آزمون');
      }
    }
  };

  const handleTimeoutExam = async () => {
    try {
      await axios.post(`/api/exam-attempts/${attemptId}/complete/`);
      router.push(`/exam/${exam.id}/results/${attemptId}`);
    } catch (error) {
      console.error('Error handling timeout:', error);
    }
  };

  if (!currentQuestion) {
    return (
      <div className="flex flex-col items-center justify-center h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            تمام سوالات پاسخ داده شدند
          </h2>
          <p className="text-gray-600 mb-6">
            آماده‌اید تا آزمون را اتمام دهید؟
          </p>
          <button
            onClick={handleCompleteExam}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition"
          >
            اتمام آزمون
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50" dir="rtl">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex-1">
            <h1 className="text-xl font-bold text-gray-800">{exam.title}</h1>
            <p className="text-sm text-gray-600">
              سوال {currentQuestion.order} از {exam.total_questions}
            </p>
          </div>
          {exam.is_timed && (
            <ExamTimer
              durationMinutes={exam.duration_minutes}
              onTimeout={handleTimeoutExam}
            />
          )}
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Question Area */}
          <div className="lg:col-span-2">
            <QuestionCard
              question={currentQuestion}
              selectedOption={selectedOption}
              onSelectOption={setSelectedOption}
            />

            {/* Navigation Buttons */}
            <div className="flex gap-4 mt-8 justify-between">
              <button
                onClick={handleCompleteExam}
                className="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition"
              >
                پایان آزمون
              </button>
              <button
                onClick={handleSubmitAnswer}
                disabled={!selectedOption || isSubmitting}
                className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 transition font-semibold"
              >
                {isSubmitting ? 'در حال ثبت...' : 'ثبت پاسخ'}
              </button>
            </div>
          </div>

          {/* Sidebar: Progress */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow p-6 sticky top-24">
              <h3 className="text-lg font-bold text-gray-800 mb-4">
                وضعیت آزمون
              </h3>
              
              <ProgressBar
                answered={progress.answered}
                correct={progress.correct}
                wrong={progress.wrong}
                unanswered={progress.unanswered}
                total={exam.total_questions}
              />

              <div className="grid grid-cols-2 gap-4 mt-6 text-center">
                <div className="bg-green-50 p-4 rounded">
                  <p className="text-2xl font-bold text-green-600">
                    {progress.correct}
                  </p>
                  <p className="text-sm text-green-700">صحیح</p>
                </div>
                <div className="bg-red-50 p-4 rounded">
                  <p className="text-2xl font-bold text-red-600">
                    {progress.wrong}
                  </p>
                  <p className="text-sm text-red-700">غلط</p>
                </div>
                <div className="col-span-2 bg-gray-50 p-4 rounded">
                  <p className="text-2xl font-bold text-gray-600">
                    {progress.unanswered}
                  </p>
                  <p className="text-sm text-gray-700">پاسخ نداده</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExamInterface;