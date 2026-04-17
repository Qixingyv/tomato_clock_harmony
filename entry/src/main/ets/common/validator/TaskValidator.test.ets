/**
 * TaskValidator 单元测试
 * 测试任务验证器的各项校验规则
 */

import { describe, it, expect } from '@ohos/hypium';
import { TaskMode } from '../../viewmodel/TaskMode';
import { TaskValidator, ValidationResult } from './TaskValidator';

export default function TaskValidatorTest() {
  describe('TaskValidator', () => {

    // ==================== 名称验证测试 ====================

    it('test_validate_name_valid', () => {
      // Act
      const result = TaskValidator.validateName('Valid Task Name');

      // Assert
      expect.assertStrictEqual(result.valid, true);
      expect.assertStrictEqual(result.errors.length, 0);
    });

    it('test_validate_name_empty', () => {
      // Act
      const result = TaskValidator.validateName('');

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.length > 0);
      expect.assertTrue(result.errors.some(e => e.includes('名称')));
    });

    it('test_validate_name_whitespace_only', () => {
      // Act
      const result = TaskValidator.validateName('   ');

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_name_too_long', () => {
      // Arrange - 名称超过50字符
      const longName = 'A'.repeat(51);

      // Act
      const result = TaskValidator.validateName(longName);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('名称')));
    });

    it('test_validate_name_with_special_chars', () => {
      // Act
      const result = TaskValidator.validateName('任务@#$%^&*()_+-=[]{}|;:\',.<>?/~`');

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_name_emoji', () => {
      // Act
      const result = TaskValidator.validateName('任务 🍅✅');

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    // ==================== 番茄时长验证测试 ====================

    it('test_validate_tomato_minutes_valid', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(25);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_tomato_minutes_minimum', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(1);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_tomato_minutes_maximum', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(120);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_tomato_minutes_zero', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(0);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('时长')));
    });

    it('test_validate_tomato_minutes_negative', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(-5);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_tomato_minutes_exceeds_maximum', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(121);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_tomato_minutes_nan', () => {
      // Act
      const result = TaskValidator.validateTomatoMinutes(NaN);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    // ==================== 休息时长验证测试 ====================

    it('test_validate_rest_minutes_valid', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(5);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_rest_minutes_minimum', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(1);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_rest_minutes_maximum', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(60);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_rest_minutes_zero', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(0);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('休息时长')));
    });

    it('test_validate_rest_minutes_negative', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(-1);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_rest_minutes_exceeds_maximum', () => {
      // Act
      const result = TaskValidator.validateRestMinutes(61);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    // ==================== 模式验证测试 ====================

    it('test_validate_mode_todo', () => {
      // Act
      const result = TaskValidator.validateMode(TaskMode.TODO);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_mode_plan', () => {
      // Act
      const result = TaskValidator.validateMode(TaskMode.PLAN);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_mode_invalid', () => {
      // Act
      const result = TaskValidator.validateMode(0);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('模式')));
    });

    // ==================== 待办模式目标番茄数验证测试 ====================

    it('test_validate_target_tomato_count_valid', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(5);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_target_tomato_count_minimum', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(1);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_target_tomato_count_maximum', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(100);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_target_tomato_count_zero', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(0);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('目标')));
    });

    it('test_validate_target_tomato_count_null', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(null);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('目标')));
    });

    it('test_validate_target_tomato_count_exceeds_maximum', () => {
      // Act
      const result = TaskValidator.validateTargetTomatoCount(101);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    // ==================== 计划模式每日目标验证测试 ====================

    it('test_validate_daily_target_tomato_count_valid', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(3);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_daily_target_tomato_count_minimum', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(1);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_daily_target_tomato_count_maximum', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(50);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_daily_target_tomato_count_zero', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(0);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('每日目标')));
    });

    it('test_validate_daily_target_tomato_count_null', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(null);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('每日目标')));
    });

    it('test_validate_daily_target_tomato_count_exceeds_maximum', () => {
      // Act
      const result = TaskValidator.validateDailyTargetTomatoCount(51);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    // ==================== 截止日期验证测试 ====================

    it('test_validate_deadline_valid', () => {
      // Arrange
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 7);

      // Act
      const result = TaskValidator.validateDeadline(futureDate);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_deadline_today', () => {
      // Arrange
      const today = new Date();
      today.setHours(23, 59, 59, 999);

      // Act
      const result = TaskValidator.validateDeadline(today);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_deadline_past', () => {
      // Arrange
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - 1);

      // Act
      const result = TaskValidator.validateDeadline(pastDate);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('截止日期')));
    });

    it('test_validate_deadline_null', () => {
      // Act
      const result = TaskValidator.validateDeadline(null);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('截止日期')));
    });

    it('test_validate_deadline_too_far', () => {
      // Arrange - 超过1年
      const farDate = new Date();
      farDate.setFullYear(farDate.getFullYear() + 2);

      // Act
      const result = TaskValidator.validateDeadline(farDate);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    // ==================== 综合验证测试 ====================

    it('test_validate_todo_task_creation_valid', () => {
      // Act
      const result = TaskValidator.validateTodoTaskCreation(
        'Valid Todo Task',
        25,
        5,
        5
      );

      // Assert
      expect.assertStrictEqual(result.valid, true);
      expect.assertStrictEqual(result.errors.length, 0);
    });

    it('test_validate_todo_task_creation_invalid', () => {
      // Act
      const result = TaskValidator.validateTodoTaskCreation(
        '',
        0,
        -1,
        0
      );

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.length >= 3);
    });

    it('test_validate_plan_task_creation_valid', () => {
      // Arrange
      const deadline = new Date();
      deadline.setDate(deadline.getDate() + 7);

      // Act
      const result = TaskValidator.validatePlanTaskCreation(
        'Valid Plan Task',
        25,
        5,
        3,
        deadline
      );

      // Assert
      expect.assertStrictEqual(result.valid, true);
      expect.assertStrictEqual(result.errors.length, 0);
    });

    it('test_validate_plan_task_creation_invalid', () => {
      // Arrange
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - 1);

      // Act
      const result = TaskValidator.validatePlanTaskCreation(
        '',
        0,
        -1,
        0,
        pastDate
      );

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.length >= 4);
    });

    it('test_validate_task_creation_todo_mode', () => {
      // Act
      const result = TaskValidator.validateTaskCreation(
        'Todo Task',
        TaskMode.TODO,
        25,
        5,
        5,
        null,
        null
      );

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_task_creation_plan_mode', () => {
      // Arrange
      const deadline = new Date();
      deadline.setDate(deadline.getDate() + 7);

      // Act
      const result = TaskValidator.validateTaskCreation(
        'Plan Task',
        TaskMode.PLAN,
        25,
        5,
        null,
        3,
        deadline
      );

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_task_creation_invalid_mode', () => {
      // Act
      const result = TaskValidator.validateTaskCreation(
        'Task',
        0,
        25,
        5,
        null,
        null,
        null
      );

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('模式')));
    });

    it('test_validate_task_update_valid', () => {
      // Act
      const result = TaskValidator.validateTaskUpdate('Updated Task Name');

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_task_update_empty', () => {
      // Act
      const result = TaskValidator.validateTaskUpdate('');

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_completed_tomato_valid', () => {
      // Act
      const result = TaskValidator.validateCompletedTomato(3, 5);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });

    it('test_validate_completed_tomato_exceeds_target', () => {
      // Act
      const result = TaskValidator.validateCompletedTomato(6, 5);

      // Assert
      expect.assertStrictEqual(result.valid, false);
      expect.assertTrue(result.errors.some(e => e.includes('超过')));
    });

    it('test_validate_completed_tomato_negative', () => {
      // Act
      const result = TaskValidator.validateCompletedTomato(-1, 5);

      // Assert
      expect.assertStrictEqual(result.valid, false);
    });

    it('test_validate_completed_tomato_equal_target', () => {
      // Act
      const result = TaskValidator.validateCompletedTomato(5, 5);

      // Assert
      expect.assertStrictEqual(result.valid, true);
    });
  });
}
