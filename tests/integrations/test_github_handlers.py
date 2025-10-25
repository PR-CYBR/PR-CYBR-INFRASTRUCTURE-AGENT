from agent_logic.github_handlers import GitHubEventHandler

def test_handle_issue_opened_triggers_triage(github_client_mock, load_payload):
    handler = GitHubEventHandler(github_client_mock)
    payload = load_payload("issue_opened")

    summary = handler.handle_issue(payload)

    github_client_mock.add_issue_comment.assert_called_once()
    repo, number, message = github_client_mock.add_issue_comment.call_args[0]
    assert repo == "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT"
    assert number == 101
    assert "Thanks for opening this issue" in message

    github_client_mock.add_issue_labels.assert_called_once_with(
        "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT", 101, [handler.triage_label]
    )
    assert "commented" in summary["actions"]
    assert "labelled" in summary["actions"]


def test_handle_pull_request_opened_requests_reviewers(github_client_mock, load_payload):
    handler = GitHubEventHandler(github_client_mock, default_reviewers=["core-maintainers"])
    payload = load_payload("pull_request_opened")

    summary = handler.handle_pull_request(payload)

    github_client_mock.add_pull_request_comment.assert_called_once()
    comment_args = github_client_mock.add_pull_request_comment.call_args[0]
    assert comment_args[0] == "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT"
    assert comment_args[1] == 5
    assert "Thanks for the pull request" in comment_args[2]

    github_client_mock.add_pull_request_labels.assert_called_once_with(
        "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT", 5, [handler.review_label]
    )
    github_client_mock.request_reviewers.assert_called_once_with(
        "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT", 5, ["core-maintainers"]
    )
    assert "requested_reviewers" in summary["actions"]


def test_handle_discussion_created_posts_guidance(github_client_mock, load_payload):
    handler = GitHubEventHandler(github_client_mock)
    payload = load_payload("discussion_created")

    handler.handle_discussion(payload)

    github_client_mock.add_discussion_comment.assert_called_once()
    args = github_client_mock.add_discussion_comment.call_args[0]
    assert args[0] == "PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT"
    assert args[1] == 2
    assert "idea" in args[2].lower()


def test_handle_project_item_created_moves_to_backlog(github_client_mock, load_payload):
    handler = GitHubEventHandler(github_client_mock, backlog_status="Ready for Triage")
    payload = load_payload("project_item_created")

    summary = handler.handle_project(payload)

    github_client_mock.update_project_item_status.assert_called_once_with(77, 441, "Ready for Triage")
    assert summary["project"] == "Infrastructure Roadmap"
    assert "moved_to_backlog" in summary["actions"]
