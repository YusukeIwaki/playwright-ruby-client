module Playwright
  # `FileChooser` objects are dispatched by the page in the [`event: Page.fileChooser`] event.
  # 
  #
  # ```js
  # const [fileChooser] = await Promise.all([
  #   page.waitForEvent('filechooser'),
  #   page.click('upload')
  # ]);
  # await fileChooser.setFiles('myfile.pdf');
  # ```
  # 
  # ```java
  # FileChooser fileChooser = page.waitForFileChooser(() -> page.click("upload"));
  # fileChooser.setFiles(Paths.get("myfile.pdf"));
  # ```
  # 
  # ```python async
  # async with page.expect_file_chooser() as fc_info:
  #     await page.click("upload")
  # file_chooser = await fc_info.value
  # await file_chooser.set_files("myfile.pdf")
  # ```
  # 
  # ```python sync
  # with page.expect_file_chooser() as fc_info:
  #     page.click("upload")
  # file_chooser = fc_info.value
  # file_chooser.set_files("myfile.pdf")
  # ```
  # 
  # ```csharp
  # var waitForFileChooserTask = page.WaitForFileChooserAsync();
  # await page.ClickAsync("upload");
  # var fileChooser = await waitForFileChooserTask;
  # await fileChooser.SetFilesAsync("temp.txt");
  # ```
  class FileChooser < PlaywrightApi

    # Returns input element associated with this file chooser.
    def element
      wrap_impl(@impl.element)
    end

    # Returns whether this file chooser accepts multiple files.
    def multiple?
      wrap_impl(@impl.multiple?)
    end

    # Returns page this file chooser belongs to.
    def page
      wrap_impl(@impl.page)
    end

    # Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths, then
    # they are resolved relative to the the current working directory. For empty array, clears the selected files.
    def set_files(files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_files(unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end
    alias_method :files=, :set_files
  end
end
