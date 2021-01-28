# API coverages

## Request

* failure
* frame
* headers
* navigation_request?
* method
* post_data
* post_data_buffer
* post_data_json
* redirected_from
* redirected_to
* resource_type
* response
* timing
* url

## Response

* ~~body~~
* ~~finished~~
* ~~frame~~
* ~~headers~~
* ~~json~~
* ~~ok~~
* ~~request~~
* ~~status~~
* ~~status_text~~
* ~~text~~
* ~~url~~

## ~~Route~~

* ~~abort~~
* ~~continue_~~
* ~~fulfill~~
* ~~request~~

## ~~WebSocket~~

* ~~closed?~~
* ~~url~~
* ~~expect_event~~

## Keyboard

* down
* insert_text
* press
* type_text
* up

## Mouse

* ~~click~~
* ~~dblclick~~
* ~~down~~
* ~~move~~
* ~~up~~

## Touchscreen

* ~~tap_point~~

## JSHandle

* as_element
* dispose
* evaluate
* evaluate_handle
* get_properties
* get_property
* json_value

## ElementHandle

* query_selector
* query_selector_all
* eval_on_selector
* eval_on_selector_all
* ~~bounding_box~~
* ~~check~~
* click
* ~~content_frame~~
* ~~dblclick~~
* ~~dispatch_event~~
* ~~fill~~
* ~~focus~~
* ~~get_attribute~~
* ~~hover~~
* ~~inner_html~~
* ~~inner_text~~
* ~~checked?~~
* ~~disabled?~~
* ~~editable?~~
* ~~enabled?~~
* ~~hidden?~~
* ~~visible?~~
* ~~owner_frame~~
* press
* ~~screenshot~~
* ~~scroll_into_view_if_needed~~
* ~~select_option~~
* ~~select_text~~
* ~~set_input_files~~
* ~~tap_point~~
* ~~text_content~~
* type_text
* ~~uncheck~~
* ~~wait_for_element_state~~
* ~~wait_for_selector~~

## ~~Accessibility~~

* ~~snapshot~~

## ~~FileChooser~~

* ~~element~~
* ~~multiple?~~
* ~~page~~
* ~~set_files~~

## Frame

* query_selector
* query_selector_all
* eval_on_selector
* eval_on_selector_all
* ~~add_script_tag~~
* ~~add_style_tag~~
* ~~check~~
* child_frames
* click
* content
* dblclick
* ~~dispatch_event~~
* evaluate
* evaluate_handle
* fill
* focus
* ~~frame_element~~
* ~~get_attribute~~
* goto
* ~~hover~~
* ~~inner_html~~
* ~~inner_text~~
* ~~checked?~~
* ~~detached?~~
* ~~disabled?~~
* ~~editable?~~
* ~~enabled?~~
* ~~hidden?~~
* ~~visible?~~
* name
* page
* parent_frame
* press
* ~~select_option~~
* set_content
* ~~set_input_files~~
* ~~tap_point~~
* ~~text_content~~
* title
* type_text
* ~~uncheck~~
* url
* ~~wait_for_function~~
* wait_for_load_state
* ~~expect_navigation~~
* ~~wait_for_selector~~
* ~~wait_for_timeout~~

## ~~Worker~~

* ~~evaluate~~
* ~~evaluate_handle~~
* ~~url~~

## Selectors

* ~~register~~

## ConsoleMessage

* args
* location
* text
* ~~type_text~~

## ~~Dialog~~

* ~~accept~~
* ~~default_value~~
* ~~dismiss~~
* ~~message~~
* ~~type_text~~

## ~~Download~~

* ~~create_read_stream~~
* ~~delete~~
* ~~failure~~
* ~~path~~
* ~~save_as~~
* ~~suggested_filename~~
* ~~url~~

## ~~Video~~

* ~~path~~

## Page

* query_selector
* query_selector_all
* eval_on_selector
* eval_on_selector_all
* ~~add_init_script~~
* ~~add_script_tag~~
* ~~add_style_tag~~
* ~~bring_to_front~~
* ~~check~~
* click
* close
* content
* context
* dblclick
* ~~dispatch_event~~
* ~~emulate_media~~
* evaluate
* evaluate_handle
* ~~expose_binding~~
* ~~expose_function~~
* fill
* focus
* frame
* frames
* ~~get_attribute~~
* ~~go_back~~
* ~~go_forward~~
* goto
* ~~hover~~
* ~~inner_html~~
* ~~inner_text~~
* ~~checked?~~
* closed?
* ~~disabled?~~
* ~~editable?~~
* ~~enabled?~~
* ~~hidden?~~
* ~~visible?~~
* main_frame
* opener
* ~~pdf~~
* press
* reload
* ~~route~~
* screenshot
* ~~select_option~~
* set_content
* ~~set_default_navigation_timeout~~
* ~~set_default_timeout~~
* ~~set_extra_http_headers~~
* ~~set_input_files~~
* set_viewport_size
* ~~tap_point~~
* ~~text_content~~
* title
* type_text
* ~~uncheck~~
* ~~unroute~~
* url
* ~~video~~
* viewport_size
* ~~expect_event~~
* ~~wait_for_function~~
* wait_for_load_state
* ~~expect_navigation~~
* ~~expect_request~~
* ~~expect_response~~
* ~~wait_for_selector~~
* ~~wait_for_timeout~~
* ~~workers~~
* accessibility
* ~~coverage~~
* keyboard
* mouse
* touchscreen

## BrowserContext

* ~~add_cookies~~
* ~~add_init_script~~
* ~~browser~~
* ~~clear_cookies~~
* ~~clear_permissions~~
* close
* ~~cookies~~
* ~~expose_binding~~
* ~~expose_function~~
* ~~grant_permissions~~
* new_page
* pages
* ~~route~~
* ~~set_default_navigation_timeout~~
* ~~set_default_timeout~~
* ~~set_extra_http_headers~~
* ~~set_geolocation~~
* ~~set_http_credentials~~
* ~~set_offline~~
* ~~storage_state~~
* ~~unroute~~
* ~~expect_event~~

## ~~CDPSession~~

* ~~detach~~
* ~~send_message~~

## ChromiumBrowserContext

* ~~background_pages~~
* ~~new_cdp_session~~
* ~~service_workers~~

## Browser

* close
* contexts
* connected?
* new_context
* new_page
* version

## BrowserType

* ~~connect~~
* executable_path
* launch
* ~~launch_persistent_context~~
* ~~launch_server~~
* name

## Playwright

* chromium
* devices
* ~~errors~~
* firefox
* ~~selectors~~
* webkit
