(* /*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
  // ****************************************************************
  // Contributor:
  // laentir Valetov
  // email:laex@bk.ru
  // ****************************************************************
  // You may retrieve the latest version of this file at the GitHub,
  // located at git://github.com/Laex/Delphi-OpenCV.git
  // ****************************************************************
  // The contents of this file are used with permission, subject to
  // the Mozilla Public License Version 1.1 (the "License"); you may
  // not use this file except in compliance with the License. You may
  // obtain a copy of the License at
  // http://www.mozilla.org/MPL/MPL-1_1Final.html
  //
  // Software distributed under the License is distributed on an
  // "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  // implied. See the License for the specific language governing
  // rights and limitations under the License.
  ******************************************************************* *)
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program cvThreshold_cvAdaptiveThreshold;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  highgui_c,
  core_c,
  Core.types_c,
  imgproc_c,
  imgproc.types_c;

const
  filename = 'Resource\cat2.jpg';

var
  src: pIplImage = nil;
  dst: pIplImage = nil;
  dst2: pIplImage = nil;

begin
  try
    // �������� ��������
    src := cvLoadImage(filename, CV_LOAD_IMAGE_GRAYSCALE);
    WriteLn(Format('[i] image: %s', [filename]));
    // ������� �����������
    cvNamedWindow('original', CV_WINDOW_AUTOSIZE);
    cvShowImage('original', src);

    dst := cvCreateImage(cvSize(src^.width, src^.height), IPL_DEPTH_8U, 1);
    dst2 := cvCreateImage(cvSize(src^.width, src^.height), IPL_DEPTH_8U, 1);

    cvThreshold(src, dst, 50, 250, CV_THRESH_BINARY);
    cvAdaptiveThreshold(src, dst2, 250, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 7, 1);

    // ���������� ����������
    cvNamedWindow('cvThreshold', CV_WINDOW_AUTOSIZE);
    cvShowImage('cvThreshold', dst);
    cvNamedWindow('cvAdaptiveThreshold', CV_WINDOW_AUTOSIZE);
    cvShowImage('cvAdaptiveThreshold', dst2);

    // ��� ������� �������
    cvWaitKey(0);

    // �c��������� ��c��c�
    cvReleaseImage(src);
    cvReleaseImage(dst);
    cvReleaseImage(dst2);
    // ������� ����
    cvDestroyAllWindows;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
