#include <sys/select.h>
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdbool.h>

static volatile bool ctrl_c_received = false;

void sigint_handler(int sig_num) {
    ctrl_c_received = true;
}

void setup_sigint_handler() {
    signal(SIGINT, sigint_handler);
}

bool was_ctrl_c_received() {
    return ctrl_c_received;
}

static struct termios oldt, newt;

void init_terminal() {
    // Get terminal attributes
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;

    // Set terminal to raw mode (no echo, non-canonical)
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
}

void restore_terminal() {
    // Restore terminal to its old state
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

char get_char_from_terminal() {
    char c = getchar();
    return c;
}

void write_char_to_terminal(char chr) {
    putchar(chr);
    fflush(stdout);
}

int is_char_available() {
    struct timeval tv;
    fd_set read_fd_set;

    // Don't wait at all, not even a microsecond
    tv.tv_sec = 0;
    tv.tv_usec = 0;

    // Watch stdin (fd 0) to see when it has input
    FD_ZERO(&read_fd_set);
    FD_SET(0, &read_fd_set);

    // Check if there's any input available
    if (select(1, &read_fd_set, NULL, NULL, &tv) == -1) {
        perror("select");
        return 0;  // 0 indicates no characters available
    }

    if (FD_ISSET(0, &read_fd_set)) {
        // Character is available
        return 1;
    } else {
        // No character available
        return 0;
    }
}