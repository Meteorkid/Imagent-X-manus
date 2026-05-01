import { expect, test } from '@playwright/test';

test.describe('offline experience', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem(
        'offline_experiment_assignment_v1',
        JSON.stringify({
          triggerVariant: 'immediate_modal',
          contentVariant: 'prompt_modal',
        }),
      );
    });
  });

  test('should show and hide offline modal on network change', async ({ page }) => {
    await page.goto('/offline-demo');
    await page.getByRole('button', { name: '模拟网络断开' }).click();
    const modalTitle = page.getByText(/网络连接已断开|网络暂时不可用/).first();
    await expect(modalTitle).toBeVisible({ timeout: 10000 });

    await page.evaluate(() => window.dispatchEvent(new Event('online')));
    await expect(modalTitle).toBeHidden({ timeout: 10000 });
  });

  test('offline dino route should load iframe content', async ({ page }) => {
    await page.goto('/offline-dino/dino');
    const iframe = page.locator('iframe[title="Offline Dino Game"]');
    await expect(iframe).toBeVisible();
    await expect(iframe).toHaveAttribute('src', '/offline-dino/dino.html');

    await page.goto('/offline-dino/dino.html');
    await expect(page.locator('canvas#gameCanvas')).toBeVisible();
  });
});

