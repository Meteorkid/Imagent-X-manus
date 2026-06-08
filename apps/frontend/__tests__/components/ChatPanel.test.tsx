import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom'
import { ChatPanel } from '../../components/chat-panel'

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

// Mock API calls
jest.mock('../../lib/api', () => ({
  streamChat: jest.fn(),
}))

// Mock hooks
jest.mock('../../hooks/use-toast', () => ({
  toast: jest.fn(),
}))

// Mock session message service
jest.mock('../../lib/session-message-service', () => ({
  getSessionMessages: jest.fn().mockResolvedValue([]),
  getSessionMessagesWithToast: jest.fn().mockResolvedValue([]),
}))

describe('ChatPanel Component', () => {
  const defaultProps = {
    conversationId: 'test-conversation-123',
    isFunctionalAgent: false,
    agentName: 'Test Agent',
  }

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render chat panel with input field', () => {
    render(<ChatPanel {...defaultProps} />)

    expect(screen.getByTestId('chat-panel')).toBeInTheDocument()
    expect(screen.getByTestId('chat-input')).toBeInTheDocument()
    expect(screen.getByTestId('send-button')).toBeInTheDocument()
  })

  it('should display agent name in header', () => {
    render(<ChatPanel {...defaultProps} />)

    expect(screen.getByText('Test Agent')).toBeInTheDocument()
  })

  it('should update input value when typing', () => {
    render(<ChatPanel {...defaultProps} />)

    const input = screen.getByTestId('chat-input')
    fireEvent.change(input, { target: { value: 'Hello, world!' } })

    expect(input).toHaveValue('Hello, world!')
  })

  it('should clear input after sending message', async () => {
    const mockStreamChat = require('../../lib/api').streamChat
    mockStreamChat.mockImplementation(() => {
      return {
        getReader: () => ({
          read: jest.fn().mockResolvedValue({ done: true }),
          releaseLock: jest.fn(),
        }),
        cancel: jest.fn(),
      }
    })

    render(<ChatPanel {...defaultProps} />)

    const input = screen.getByTestId('chat-input')
    const sendButton = screen.getByTestId('send-button')

    fireEvent.change(input, { target: { value: 'Hello, world!' } })
    fireEvent.click(sendButton)

    await waitFor(() => {
      expect(input).toHaveValue('')
    })
  })

  it('should disable send button when input is empty', () => {
    render(<ChatPanel {...defaultProps} />)

    const sendButton = screen.getByTestId('send-button')
    expect(sendButton).toBeDisabled()
  })

  it('should enable send button when input has content', () => {
    render(<ChatPanel {...defaultProps} />)

    const input = screen.getByTestId('chat-input')
    const sendButton = screen.getByTestId('send-button')

    fireEvent.change(input, { target: { value: 'Hello' } })

    expect(sendButton).not.toBeDisabled()
  })

  it('should show loading state initially', () => {
    render(<ChatPanel {...defaultProps} />)

    expect(screen.getByTestId('chat-loading')).toBeInTheDocument()
  })

  it('should display empty state when no messages', async () => {
    render(<ChatPanel {...defaultProps} />)

    await waitFor(() => {
      expect(screen.getByText('开始新的对话')).toBeInTheDocument()
    })
  })

  it('should handle keyboard shortcuts', () => {
    render(<ChatPanel {...defaultProps} />)

    const input = screen.getByTestId('chat-input')
    fireEvent.change(input, { target: { value: 'Hello' } })

    // Press Enter without Shift
    fireEvent.keyDown(input, { key: 'Enter', shiftKey: false })

    // Should send message (input cleared)
    expect(input).toHaveValue('')
  })

  it('should not send message on Shift+Enter', () => {
    render(<ChatPanel {...defaultProps} />)

    const input = screen.getByTestId('chat-input')
    fireEvent.change(input, { target: { value: 'Hello' } })

    // Press Shift+Enter
    fireEvent.keyDown(input, { key: 'Enter', shiftKey: true })

    // Should not clear input (new line)
    expect(input).toHaveValue('Hello')
  })

  it('should toggle scheduled task panel when button clicked', () => {
    const mockToggle = jest.fn()
    render(<ChatPanel {...defaultProps} onToggleScheduledTaskPanel={mockToggle} />)

    const scheduledTaskButton = screen.getByTestId('scheduled-task-button')
    fireEvent.click(scheduledTaskButton)

    expect(mockToggle).toHaveBeenCalled()
  })

  it('should show multi-modal upload when enabled', () => {
    render(<ChatPanel {...defaultProps} multiModal={true} />)

    expect(screen.getByTestId('multi-modal-upload')).toBeInTheDocument()
  })

  it('should hide multi-modal upload when disabled', () => {
    render(<ChatPanel {...defaultProps} multiModal={false} />)

    expect(screen.queryByTestId('multi-modal-upload')).not.toBeInTheDocument()
  })
})
