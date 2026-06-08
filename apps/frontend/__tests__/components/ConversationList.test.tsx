import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom'
import { ConversationList } from '../../components/conversation-list'

// Mock next/router
jest.mock('next/router', () => ({
  useRouter() {
    return {
      push: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn().mockResolvedValue(undefined),
    }
  },
}))

// Mock workspace context
jest.mock('../../contexts/workspace-context', () => ({
  useWorkspace: () => ({
    selectedConversationId: 'conv-1',
    setSelectedConversationId: jest.fn(),
  }),
}))

// Mock agent session service
jest.mock('../../lib/agent-session-service', () => ({
  getAgentSessionsWithToast: jest.fn().mockResolvedValue({
    code: 200,
    data: [
      { id: 'conv-1', title: 'Test Conversation 1', createdAt: '2024-01-01' },
      { id: 'conv-2', title: 'Test Conversation 2', createdAt: '2024-01-02' },
    ],
  }),
  createAgentSessionWithToast: jest.fn().mockResolvedValue({
    code: 200,
    data: { id: 'conv-3', title: 'New Conversation' },
  }),
  updateAgentSessionWithToast: jest.fn().mockResolvedValue({
    code: 200,
    data: { id: 'conv-3', title: 'Updated Title' },
  }),
  deleteAgentSessionWithToast: jest.fn().mockResolvedValue({
    code: 200,
  }),
}))

// Mock hooks
jest.mock('../../hooks/use-toast', () => ({
  toast: jest.fn(),
}))

describe('ConversationList Component', () => {
  const defaultProps = {
    workspaceId: 'workspace-123',
  }

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render conversation list', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
      expect(screen.getByText('Test Conversation 2')).toBeInTheDocument()
    })
  })

  it('should show loading state initially', () => {
    render(<ConversationList {...defaultProps} />)

    expect(screen.getByTestId('conversation-loading')).toBeInTheDocument()
  })

  it('should display empty state when no conversations', async () => {
    const mockGetSessions = require('../../lib/agent-session-service').getAgentSessionsWithToast
    mockGetSessions.mockResolvedValueOnce({
      code: 200,
      data: [],
    })

    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('暂无会话')).toBeInTheDocument()
    })
  })

  it('should open create dialog when add button clicked', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    const addButton = screen.getByTestId('add-conversation-button')
    fireEvent.click(addButton)

    expect(screen.getByText('创建新会话')).toBeInTheDocument()
  })

  it('should create new conversation when form submitted', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    // Open create dialog
    const addButton = screen.getByTestId('add-conversation-button')
    fireEvent.click(addButton)

    // Fill in the title
    const titleInput = screen.getByTestId('new-conversation-title')
    fireEvent.change(titleInput, { target: { value: 'New Conversation' } })

    // Submit form
    const createButton = screen.getByText('创建')
    fireEvent.click(createButton)

    await waitFor(() => {
      expect(require('../../lib/agent-session-service').createAgentSessionWithToast).toHaveBeenCalled()
    })
  })

  it('should not create conversation with empty title', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    // Open create dialog
    const addButton = screen.getByTestId('add-conversation-button')
    fireEvent.click(addButton)

    // Submit form without title
    const createButton = screen.getByText('创建')
    fireEvent.click(createButton)

    await waitFor(() => {
      expect(require('../../hooks/use-toast').toast).toHaveBeenCalledWith({
        description: '会话标题不能为空',
        variant: 'destructive',
      })
    })
  })

  it('should select conversation when clicked', async () => {
    const mockSetSelected = jest.fn()
    require('../../contexts/workspace-context').useWorkspace.mockReturnValue({
      selectedConversationId: null,
      setSelectedConversationId: mockSetSelected,
    })

    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    const conversationItem = screen.getByText('Test Conversation 1')
    fireEvent.click(conversationItem)

    expect(mockSetSelected).toHaveBeenCalledWith('conv-1')
  })

  it('should open rename dialog when rename button clicked', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    // Click more options button
    const moreButton = screen.getByTestId('more-options-conv-1')
    fireEvent.click(moreButton)

    // Click rename option
    const renameOption = screen.getByText('重命名')
    fireEvent.click(renameOption)

    expect(screen.getByText('重命名会话')).toBeInTheDocument()
  })

  it('should open delete dialog when delete button clicked', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    // Click more options button
    const moreButton = screen.getByTestId('more-options-conv-1')
    fireEvent.click(moreButton)

    // Click delete option
    const deleteOption = screen.getByText('删除')
    fireEvent.click(deleteOption)

    expect(screen.getByText('确认删除')).toBeInTheDocument()
  })

  it('should delete conversation when confirmed', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    // Click more options button
    const moreButton = screen.getByTestId('more-options-conv-1')
    fireEvent.click(moreButton)

    // Click delete option
    const deleteOption = screen.getByText('删除')
    fireEvent.click(deleteOption)

    // Confirm deletion
    const confirmButton = screen.getByText('删除')
    fireEvent.click(confirmButton)

    await waitFor(() => {
      expect(require('../../lib/agent-session-service').deleteAgentSessionWithToast).toHaveBeenCalledWith('conv-1')
    })
  })

  it('should filter conversations by search text', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
      expect(screen.getByText('Test Conversation 2')).toBeInTheDocument()
    })

    // Search for "Conversation 1"
    const searchInput = screen.getByTestId('search-conversations')
    fireEvent.change(searchInput, { target: { value: 'Conversation 1' } })

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
      expect(screen.queryByText('Test Conversation 2')).not.toBeInTheDocument()
    })
  })

  it('should toggle collapse state', async () => {
    render(<ConversationList {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('Test Conversation 1')).toBeInTheDocument()
    })

    const collapseButton = screen.getByTestId('collapse-button')
    fireEvent.click(collapseButton)

    // Should hide conversation list
    expect(screen.queryByText('Test Conversation 1')).not.toBeInTheDocument()
  })
})
