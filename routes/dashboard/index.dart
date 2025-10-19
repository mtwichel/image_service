// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_html/dart_frog_html.dart';

Future<Response> onRequest(RequestContext context) async {
  return HtmlResponse(
    context: context,
    body: Html(
      children: [
        Head(
          children: [
            Title(children: [const Text('Image Dashboard')]),
            Meta(
              attributes: {
                'name': 'viewport',
                'content': 'width=device-width, initial-scale=1.0',
              },
            ),
            Script(attributes: {'src': 'https://unpkg.com/htmx.org@1.9.10'}),
            Script(
              attributes: {'src': 'https://unpkg.com/hyperscript.org@0.9.12'},
            ),
            Script(
              attributes: {
                'src': 'https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4',
              },
            ),
            Link(attributes: {'rel': 'stylesheet', 'href': '/main.css'}),
          ],
        ),
        Body(
          className: 'min-h-screen p-4 md:p-8 font-sans text-gray-800',
          children: [
            Div(
              className:
                  'max-w-6xl mx-auto bg-white rounded-xl shadow-2xl overflow-hidden',
              children: [
                Div(
                  className:
                      'bg-gradient-to-r from-slate-800 to-slate-700 text-white p-8 text-center',
                  children: [
                    H1(
                      className: 'text-3xl md:text-4xl font-light mb-2',
                      children: [const Text('Image Dashboard')],
                    ),
                  ],
                ),
                Div(
                  className: 'p-4 md:p-8',
                  children: [
                    Form(
                      className:
                          'mb-8 p-6 bg-white rounded-lg border border-gray-200 shadow-sm',
                      attributes: {
                        'hx-post': '/dashboard/files/',
                        'hx-encoding': 'multipart/form-data',
                        'hx-target': '#table-body',
                        'hx-swap': 'afterbegin',
                        'id': 'upload-form',
                      },
                      children: [
                        Div(
                          className: 'mb-4',
                          children: [
                            H3(
                              className:
                                  'text-lg font-semibold mb-2 text-gray-800',
                              children: [const Text('Upload Image')],
                            ),
                            P(
                              className: 'text-gray-600 text-sm',
                              children: [
                                const Text(
                                  'Select an image file to upload (max 10MB)',
                                ),
                              ],
                            ),
                          ],
                        ),
                        Div(
                          className: 'space-y-4',
                          children: [
                            Div(
                              children: [
                                Label(
                                  className:
                                      'block text-sm font-medium text-gray-700 mb-2',
                                  children: [const Text('Bucket (Optional)')],
                                ),
                                Input(
                                  className:
                                      'w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
                                  attributes: {
                                    'type': 'text',
                                    'name': 'bucket',
                                    'placeholder':
                                        'Enter bucket name for organization...',
                                    'id': 'bucket-input',
                                  },
                                ),
                                P(
                                  className: 'mt-1 text-xs text-gray-500',
                                  children: [
                                    const Text(
                                      'Leave empty for default storage or specify a bucket to organize images',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Div(
                              children: [
                                Label(
                                  className:
                                      'block text-sm font-medium text-gray-700 mb-2',
                                  children: [const Text('Choose Image File')],
                                ),
                                Div(
                                  className:
                                      'w-full p-6 border-2 border-dashed border-gray-300 rounded-md bg-gray-50 text-center transition-all duration-200 hover:border-blue-400 hover:bg-blue-50 cursor-pointer',
                                  attributes: {'id': 'drop-zone'},
                                  children: [
                                    Div(
                                      className: 'mb-2',
                                      children: [
                                        Div(
                                          className:
                                              'w-8 h-8 mx-auto mb-2 text-gray-400',
                                          children: [const Text('📁')],
                                        ),
                                        P(
                                          className:
                                              'text-sm text-gray-600 mb-1',
                                          attributes: {'id': 'drop-text'},
                                          children: [
                                            const Text(
                                              'Drag and drop your image here',
                                            ),
                                          ],
                                        ),
                                        P(
                                          className: 'text-xs text-gray-500',
                                          children: [
                                            const Text('or click to browse'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Input(
                                      className: 'hidden',
                                      attributes: {
                                        'type': 'file',
                                        'name': 'file',
                                        'accept': 'image/*',
                                        'required': '',
                                        'id': 'file-input',
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Button(
                              className:
                                  'w-full bg-blue-600 text-white border-none py-3 px-6 rounded-md cursor-pointer text-sm font-medium hover:bg-blue-700 transition-colors',
                              attributes: {'type': 'submit'},
                              children: [const Text('Upload Image')],
                            ),
                          ],
                        ),
                        Progress(
                          className:
                              'mt-4 w-full h-2 rounded-full overflow-hidden appearance-none [&::-webkit-progress-bar]:bg-gray-200 [&::-webkit-progress-bar]:rounded-full [&::-webkit-progress-value]:bg-blue-600 [&::-webkit-progress-value]:rounded-full [&::-moz-progress-bar]:bg-blue-600 [&::-moz-progress-bar]:rounded-full opacity-0 [&[value]:not([value="0"])]:opacity-100 transition-opacity duration-300',
                          attributes: {
                            'id': 'progress',
                            'value': '0',
                            'max': '100',
                          },
                        ),
                        Div(
                          className:
                              'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-green-100 [&:not(:empty)]:text-green-700 [&:not(:empty)]:border [&:not(:empty)]:border-green-300',
                          attributes: {'id': 'upload-result'},
                        ),
                      ],
                    ),
                    Div(
                      className:
                          'mb-6 p-4 bg-white rounded-lg border border-gray-200 shadow-sm',
                      children: [
                        H3(
                          className: 'text-lg font-semibold mb-3 text-gray-800',
                          children: [const Text('Filter Images')],
                        ),
                        Div(
                          className: 'relative',
                          children: [
                            Input(
                              className:
                                  'w-full px-4 py-2 pr-10 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
                              attributes: {
                                'type': 'text',
                                'id': 'image-filter',
                                'placeholder': 'Search by original filename...',
                              },
                            ),
                            Button(
                              className:
                                  'absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 focus:outline-none hidden',
                              attributes: {
                                'type': 'button',
                                'id': 'clear-filter',
                                'title': 'Clear search',
                              },
                              children: [const Text('✕')],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Div(
                      attributes: {'id': 'images-table'},
                      children: [
                        Div(
                          className: 'text-center py-8',
                          children: [const Text('Loading images...')],
                        ),
                        Div(
                          className: 'text-center mt-4',
                          children: [
                            Button(
                              className:
                                  'px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors cursor-pointer',
                              attributes: {'id': 'reset-api-key'},
                              children: [const Text('Change API Key')],
                            ),
                            P(
                              className: 'text-xs text-gray-500 mt-2',
                              children: [
                                const Text(
                                  'Or press Ctrl+Shift+K (⌘+Shift+K on Mac)',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Script(attributes: {'src': '/main.js'}),
          ],
        ),
      ],
    ),
  );
}
