import { expect, test } from "@playwright/test"

test("login page should render entry state", async ({ page }) => {
  await page.goto("/login")
  await expect(page).toHaveURL(/\/login/)

  const heading = page.getByRole("heading", {
    name: /登录|暂时无法登录/,
  })
  await expect(heading).toBeVisible()
})
