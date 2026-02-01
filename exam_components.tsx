// medicalpromax_frontend/src/components/exam/QuestionCard.tsx
/**
 * Question display card component
 * Shows question text, image, and answer options
 */

'use client';

import React from 'react';

interface Option {
  id: number;
  option_number: number;
  option_text: string;
  option_html?: string;
}

interface Question {
  id: number;
  order: number;
  question_text: string;
  question_html?: string;
  image_url?: string;
  options: Option[];
}

interface QuestionCardProps {
  question: Question;
  selectedOption: number | null;
  onSelectOption: (optionId: number) => void;
}

const QuestionCard: React.FC<QuestionCardProps> = ({
  question,
  selectedOption,
  onSelectOption,
}) => {
  return (
    <div className="bg-white rounded-lg shadow-lg p-8" dir="rtl">
      {/* Question Number & Difficulty */}
      <div className="flex items-center justify-between mb-6 pb-6 border-b border-gray-200">
        <h2 className="text-2xl font-bold text-gray-800">
          سوال {question.order}
        </h2>
      </div>

      {/* Question Text */}
      <div className="mb-6">
        {question.question_html ? (
          <div
            className="text-lg text-gray-700 leading-relaxed"
            dangerouslySetInnerHTML={{ __html: question.question_html }}
          />
        ) : (
          <p className="text-lg text-gray-700 leading-relaxed">
            {question.question_text}
          </p>
        )}
      </div>

      {/* Question Image */}
      {question.image_url && (
        <div className="mb-6 flex justify-center">
          <img
            src={question.image_url}
            alt="سوال"
            className="max-w-md max-h-96 rounded-lg border border-gray-300"
          />
        </div>
      )}

      {/* Answer Options */}
      <div className="space-y-3 mt-8">
        {question.options.map((option) => (
          <button
            key={option.id}
            onClick={() => onSelectOption(option.id)}
            className={`w-full p-4 text-right rounded-lg border-2 transition-all ${
              selectedOption === option.id
                ? 'border-blue-600 bg-blue-50'
                : 'border-gray-300 bg-white hover:border-gray-400'
            }`}
          >
            <div className="flex items-center">
              <div
                className={`w-6 h-6 rounded-full border-2 ml-4 flex items-center justify-center ${
                  selectedOption === option.id
                    ? 'border-blue-600 bg-blue-600'
                    : 'border-gray-400'
                }`}
              >
                {selectedOption === option.id && (
                  <div className="w-2 h-2 bg-white rounded-full" />
                )}
              </div>
              <span className="text-lg text-gray-700">
                {String.fromCharCode(64 + option.option_number)}) {option.option_text}
              </span>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};

export default QuestionCard;


// medicalpromax_frontend/src/components/exam/ExamTimer.tsx
/**
 * Countdown timer component for timed exams
 */

'use client';

import React, { useState, useEffect } from 'react';

interface ExamTimerProps {
  durationMinutes: number;
  onTimeout: () => void;
}

const ExamTimer: React.FC<ExamTimerProps> = ({ durationMinutes, onTimeout }) => {
  const [timeLeft, setTimeLeft] = useState(durationMinutes * 60);

  useEffect(() => {
    if (timeLeft <= 0) {
      onTimeout();
      return;
    }

    const timer = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, onTimeout]);

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;
  const isWarning = timeLeft < 300; // Last 5 minutes

  return (
    <div
      className={`text-2xl font-bold font-mono px-4 py-2 rounded-lg ${
        isWarning
          ? 'bg-red-100 text-red-700'
          : 'bg-blue-100 text-blue-700'
      }`}
    >
      {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
    </div>
  );
};

export default ExamTimer;


// medicalpromax_frontend/src/components/exam/ProgressBar.tsx
/**
 * Progress visualization component
 */

'use client';

import React from 'react';

interface ProgressBarProps {
  answered: number;
  correct: number;
  wrong: number;
  unanswered: number;
  total: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({
  answered,
  correct,
  wrong,
  unanswered,
  total,
}) => {
  const answeredPercent = (answered / total) * 100;
  const correctPercent = (correct / total) * 100;
  const wrongPercent = (wrong / total) * 100;
  const unansweredPercent = (unanswered / total) * 100;

  return (
    <div>
      <div className="mb-2">
        <div className="h-4 bg-gray-200 rounded-full overflow-hidden flex">
          <div
            className="bg-green-500"
            style={{ width: `${correctPercent}%` }}
            title={`صحیح: ${correct}`}
          />
          <div
            className="bg-red-500"
            style={{ width: `${wrongPercent}%` }}
            title={`غلط: ${wrong}`}
          />
          <div
            className="bg-yellow-400"
            style={{ width: `${unansweredPercent}%` }}
            title={`پاسخ نداده: ${unanswered}`}
          />
        </div>
      </div>
      <div className="text-sm text-gray-600 text-center">
        {answered} از {total} پاسخ داده شده
      </div>
    </div>
  );
};

export default ProgressBar;