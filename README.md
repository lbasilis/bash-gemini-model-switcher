# 🤖 Gemini Bash CLI Interactive Chat

An interactive, lightweight Command Line Interface (CLI) chat application written in pure Bash script. It connects directly to Google's Gemini API, maintaining full conversation context and offering colorful terminal output.

---

## ✨ Features

* **Interactive Chat Loop:** Chat seamlessly with Google's Gemini models directly inside your terminal.
* **Context Awareness:** Automatically maintains conversation history across prompts using `jq`.
* **Dynamic Model Switching:** Easily switch between different Gemini models on the fly.
* **Colorful Terminal UI:** Enhanced readability with color-coded user, model, and system output.
* **Graceful Error Handling:** Automatically catches API errors and prevents memory corruption on failed requests.

---

## 📋 Prerequisites

Before running the script, make sure you have the following installed on your system:

* **Bash** (`bash` shell)
* **cURL** (`curl`): Used to issue POST requests to the API.
* **jq** (`jq`): Used for lightweight JSON processing in the terminal.

### Installing Dependencies

* **macOS:**
  ```bash
  brew install jq curl
  ```
* **Ubuntu / Debian:**
  ```bash
  sudo apt-get update && sudo apt-get install jq curl
  ```
* **Arch Linux:**
  ```bash
  sudo pacman -S jq curl
  ```

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/lbasilis/bash-gemini-model-switcher.git
cd bash-gemini-model-switcher
```

### 2. Configure Your API Key
Open the script file in a text editor and paste your Google Gemini API key into the `API_KEY` variable near the top:

```bash
# =====================================================================
# 🔑 CONFIGURATION: INSERT YOUR GEMINI API KEY BELOW 🔑
# =====================================================================
API_KEY="YOUR_ACTUAL_GEMINI_API_KEY"
DEFAULT_MODEL="gemini-3.5-flash-lite"
# =====================================================================
```

### 3. Make the Script Executable
```bash
chmod +x g-models.sh
```

### 4. Run the Script
```bash
./g-models.sh
```

---

## 🕹️ In-Chat Commands

Once the CLI is running, you can use the following commands:

| Command | Description |
| :--- | :--- |
| `/model <model_name>` | Switch to a different model (e.g., `/model gemini-2.5-flash`). Resets context history. |
| `/clear` | Clears the terminal screen and resets conversation history. |
| `/quit` or `/exit` | Exits the interactive chat session. |

---

## ⚠️ Notes

* **Context Resets:** Changing models using `/model` will clear your chat memory to prevent model context mismatch errors.
* **Security:** Be careful not to commit your script containing your hardcoded API key to public repositories.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
