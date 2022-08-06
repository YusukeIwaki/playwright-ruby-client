# API coverages

## Request

* all_headers
* failure
* frame
* headers
* headers_array
* header_value
* navigation_request?
* method
* post_data
* post_data_buffer
* post_data_json
* redirected_from
* redirected_to
* resource_type
* response
* sizes
* timing
* url

## Response

* all_headers
* body
* finished
* frame
* from_service_worker
* headers
* headers_array
* header_value
* header_values
* json
* ok
* request
* security_details
* server_addr
* status
* status_text
* text
* url

## Route

* abort
* continue
* fallback
* fulfill
* request

## WebSocket

* closed?
* url
* expect_event
* wait_for_event

## Keyboard

* down
* insert_text
* press
* type
* up

## Mouse

* click
* dblclick
* down
* move
* up
* wheel

## Touchscreen

* tap_point

## JSHandle

* as_element
* dispose
* evaluate
* evaluate_handle
* get_properties
* get_property
* json_value

## ElementHandle

* bounding_box
* check
* click
* content_frame
* dblclick
* dispatch_event
* eval_on_selector
* eval_on_selector_all
* fill
* focus
* get_attribute
* hover
* inner_html
* inner_text
* input_value
* checked?
* disabled?
* editable?
* enabled?
* hidden?
* visible?
* owner_frame
* press
* query_selector
* query_selector_all
* screenshot
* scroll_into_view_if_needed
* select_option
* select_text
* set_checked
* set_input_files
* tap_point
* text_content
* type
* uncheck
* wait_for_element_state
* wait_for_selector

## Accessibility

* snapshot

## FileChooser

* element
* multiple?
* page
* set_files

## Frame

* add_script_tag
* add_style_tag
* check
* child_frames
* click
* content
* dblclick
* dispatch_event
* drag_and_drop
* eval_on_selector
* eval_on_selector_all
* evaluate
* evaluate_handle
* fill
* focus
* frame_element
* frame_locator
* get_attribute
* goto
* hover
* inner_html
* inner_text
* input_value
* checked?
* detached?
* disabled?
* editable?
* enabled?
* hidden?
* visible?
* locator
* name
* page
* parent_frame
* press
* query_selector
* query_selector_all
* select_option
* set_checked
* set_content
* set_input_files
* tap_point
* text_content
* title
* type
* uncheck
* url
* wait_for_function
* wait_for_load_state
* expect_navigation
* wait_for_selector
* wait_for_timeout
* wait_for_url

## Worker

* evaluate
* evaluate_handle
* url

## Selectors

* register

## ConsoleMessage

* args
* location
* text
* type

## Dialog

* accept
* default_value
* dismiss
* message
* type

## Download

* cancel
* delete
* failure
* page
* path
* save_as
* suggested_filename
* url

## Page

* add_init_script
* add_script_tag
* add_style_tag
* bring_to_front
* check
* click
* close
* content
* context
* dblclick
* dispatch_event
* drag_and_drop
* emulate_media
* eval_on_selector
* eval_on_selector_all
* evaluate
* evaluate_handle
* expose_binding
* expose_function
* fill
* focus
* frame
* frame_locator
* frames
* get_attribute
* go_back
* go_forward
* goto
* hover
* inner_html
* inner_text
* input_value
* checked?
* closed?
* disabled?
* editable?
* enabled?
* hidden?
* visible?
* locator
* main_frame
* opener
* pause
* pdf
* press
* query_selector
* query_selector_all
* reload
* route
* route_from_har
* screenshot
* select_option
* set_checked
* set_content
* set_default_navigation_timeout
* set_default_timeout
* set_extra_http_headers
* set_input_files
* set_viewport_size
* tap_point
* text_content
* title
* type
* uncheck
* unroute
* url
* video
* viewport_size
* expect_console_message
* expect_download
* expect_event
* expect_file_chooser
* wait_for_function
* wait_for_load_state
* expect_navigation
* expect_popup
* expect_request
* expect_request_finished
* expect_response
* wait_for_selector
* wait_for_timeout
* wait_for_url
* expect_websocket
* expect_worker
* workers
* ~~wait_for_event~~
* accessibility
* keyboard
* mouse
* request
* touchscreen

## BrowserContext

* add_cookies
* add_init_script
* background_pages
* browser
* clear_cookies
* clear_permissions
* close
* cookies
* expose_binding
* expose_function
* grant_permissions
* new_cdp_session
* new_page
* pages
* route
* route_from_har
* service_workers
* set_default_navigation_timeout
* set_default_timeout
* set_extra_http_headers
* set_geolocation
* set_offline
* storage_state
* unroute
* expect_event
* expect_page
* ~~wait_for_event~~
* request
* tracing

## CDPSession

* detach
* send_message

## Browser

* browser_type
* close
* contexts
* connected?
* new_browser_cdp_session
* new_context
* new_page
* start_tracing
* stop_tracing
* version

## BrowserType

* ~~connect~~
* connect_over_cdp
* executable_path
* launch
* launch_persistent_context
* name

## Playwright

* ~~stop~~
* chromium
* devices
* firefox
* ~~request~~
* selectors
* webkit

## Tracing

* start
* start_chunk
* stop
* stop_chunk

## Locator

* all_inner_texts
* all_text_contents
* bounding_box
* check
* click
* count
* dblclick
* dispatch_event
* drag_to
* element_handle
* element_handles
* evaluate
* evaluate_all
* evaluate_handle
* fill
* filter
* first
* focus
* frame_locator
* get_attribute
* highlight
* hover
* inner_html
* inner_text
* input_value
* checked?
* disabled?
* editable?
* enabled?
* hidden?
* visible?
* last
* locator
* nth
* page
* press
* screenshot
* scroll_into_view_if_needed
* select_option
* select_text
* set_checked
* set_input_files
* tap_point
* text_content
* type
* uncheck
* wait_for

## FrameLocator

* first
* frame_locator
* last
* locator
* nth

## LocalUtils


## APIResponse

* body
* dispose
* headers
* headers_array
* json
* ok
* status
* status_text
* text
* url

## APIRequestContext

* delete
* dispose
* fetch
* get
* head
* patch
* post
* put
* ~~storage_state~~

## ~~APIRequest~~

* ~~new_context~~

## Android

* devices
* ~~set_default_timeout~~

## AndroidDevice

* close
* ~~drag~~
* ~~fill~~
* ~~fling~~
* info
* ~~install_apk~~
* launch_browser
* ~~long_tap~~
* model
* ~~open~~
* ~~pinch_close~~
* ~~pinch_open~~
* ~~press~~
* ~~push~~
* screenshot
* ~~scroll~~
* serial
* ~~set_default_timeout~~
* shell
* ~~swipe~~
* ~~tap_point~~
* ~~wait~~
* ~~wait_for_event~~
* ~~web_view~~
* ~~web_views~~
* input

## AndroidInput

* drag
* press
* ~~swipe~~
* tap_point
* type

## ~~AndroidSocket~~

* ~~close~~
* ~~write~~

## ~~AndroidWebView~~

* ~~page~~
* ~~pid~~
* ~~pkg~~
