# Plugin Example for hexDEV's hex-browser

A Qt C++/QML-based example plugin, demonstrating integration into
[hexDEV GmbH](https://hexdev.de) its hex-browser application.
This project provides both:

- A dynamic plugin (`plugin_example_hex_browser`) for integration into hex-browser.
- A standalone executable (`example_hex_browser`) for easy testing, debugging, and development.

## Requirements

- **Qt6** (minimum version 6.8)
- **CMake** (minimum version 3.10)

Ensure these are installed and properly configured.

## Building the Project

### Step-by-Step Instructions

```bash
git clone <repository-url>
cd plugin_example_hex_browser
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

## Running the Standalone Application

After building, run the standalone executable directly:

```bash
./example_hex_browser
```

## Integration into hexDEV's hex-browser

To use the plugin in [hexDEV GmbH](https://hexdev.de) its hex-browser:

- Build the plugin library (`plugin_example_hex_browser`).
- Just set the URL in hex-browser to the plugin library destination, like file://persistency/plugin_example_hex_browser.so 

## License

This project is licensed under the **MIT License**.

See [LICENSE](LICENSE) for details.