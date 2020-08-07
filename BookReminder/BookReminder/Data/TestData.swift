//
//  TestData.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/05.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

let jsonData: Data = """
{
    documents =     (
                {
            authors =             (
                "\\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c",
                "\\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00"
            );
            contents = "\\Uadf8\\Uc758 \\Uace0\\Ubbfc\\Uc5d0 \\U201c\\Uc778\\Uac04\\Uc740 \\Ubcc0\\Ud560 \\Uc218 \\Uc788\\Uace0, \\Ub204\\Uad6c\\Ub098 \\Ud589\\Ubcf5\\Ud574 \\Uc9c8 \\Uc218 \\Uc788\\Ub2e4. \\Ub2e8 \\Uadf8\\Ub7ec\\Uae30 \\Uc704\\Ud574\\Uc11c\\Ub294 \\U2018\\Uc6a9\\Uae30\\U2019\\Uac00 \\Ud544\\Uc694\\Ud558\\Ub2e4\\U201d\\Uace0 \\Ub9d0\\Ud55c \\Ucca0\\Ud559\\Uc790\\Uac00 \\Uc788\\Ub2e4. \\Ubc14\\Ub85c \\Ud504\\Ub85c\\Uc774\\Ud2b8, \\Uc735\\Uacfc \\Ud568\\Uaed8 \\U2018\\Uc2ec\\Ub9ac\\Ud559\\Uc758 3\\Ub300 \\Uac70\\Uc7a5\\U2019\\Uc73c\\Ub85c \\Uc77c\\Uceec\\Uc5b4\\Uc9c0\\Uace0 \\Uc788\\Ub294 \\Uc54c\\Ud504\\Ub808\\Ub4dc \\Uc544\\Ub4e4\\Ub7ec\\Ub2e4.  \\U300e\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30\\U300f\\Ub294 \\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc5d0 \\Uad00\\Ud55c \\Uc77c\\Ubcf8\\Uc758 1\\Uc778\\Uc790 \\Ucca0\\Ud559\\Uc790 \\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c\\Uc640 \\Ubca0\\Uc2a4\\Ud2b8\\Uc140\\Ub7ec \\Uc791\\Uac00\\Uc778 \\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00\\Uc758 \\Uc800\\Uc11c\\Ub85c, \\Uc544\\Ub4e4\\Ub7ec\\Uc758 \\Uc2ec\\Ub9ac\\Ud559\\Uc744 \\U2018\\Ub300\\Ud654\\Uccb4\\U2019\\Ub85c \\Uc27d\\Uace0 \\Ub9db\\Uae54\\Ub098\\Uac8c \\Uc815\\Ub9ac\\Ud558\\Uace0 \\Uc788\\Ub2e4. \\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc744 \\Uacf5\\Ubd80\\Ud55c \\Ucca0\\Ud559\\Uc790\\Uc640 \\Uc138\\Uc0c1\\Uc5d0 \\Ubd80\\Uc815\\Uc801\\Uc774\\Uace0 \\Uc5f4\\Ub4f1\\Uac10";
            datetime = "2014-11-17T00:00:00.000+09:00";
            isbn = "8996991341 9788996991342";
            price = 14900;
            publisher = "\\Uc778\\Ud50c\\Ub8e8\\Uc5d4\\Uc15c";
            "sale_price" = 13410;
            status = "\\Uc815\\Uc0c1\\Ud310\\Ub9e4";
            thumbnail = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1467038%3Ftimestamp%3D20200803133758";
            title = "\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30";
            translators =             (
                "\\Uc804\\Uacbd\\Uc544"
            );
            url = "https://search.daum.net/search?w=bookpage&bookId=1467038&q=%EB%AF%B8%EC%9B%80%EB%B0%9B%EC%9D%84+%EC%9A%A9%EA%B8%B0";
        },
                {
            authors =             (
                "\\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c",
                "\\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00"
            );
            contents = "\\Uc774\\Ubbf8 \\Uc774 \\Uc2dc\\Ub300\\Uc758 \\Uace0\\Uc804\\Uc774 \\Ub41c \\Ucc45! 2015\\Ub144, 2016\\Ub144, 2017\\Ub144 \\Uc555\\Ub3c4\\Uc801 \\Uc778\\Uae30\\Uc758 \\Uc778\\Ubb38 \\Uad50\\Uc591\\Uc11c \\Uc2dc\\Ub9ac\\Uc988\\Ub97c \\Ud55c \\Uad8c\\Uc73c\\Ub85c \\Ub9cc\\Ub09c\\Ub2e4!  \\Uc5ed\\Ub300 \\Ucd5c\\Uc7a5\\Uae30\\Uac04 \\Uc5f0\\Uc18d \\Ubca0\\Uc2a4\\Ud2b8\\Uc140\\Ub7ec 1\\Uc704\\Uc758 \\U300e\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30\\U300f\\Uc640 \\Ucd9c\\Uac04 \\Ud55c \\Ub2ec \\Ub9cc\\Uc5d0 15\\Ub9cc \\Ubd80 \\Ud310\\Ub9e4\\Uc758 \\U300e\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30 2\\U300f\\Ub97c \\Ub3d9\\Uc2dc\\Uc5d0 \\Ub9cc\\Ub098\\Ub294 \\Ub2e8 \\Ud55c \\Ubc88\\Uc758 \\Uae30\\Ud68c!  \\Uc778\\Uac04\\Uc740 \\Ub204\\Uad6c\\Ub098 \\Ubcc0\\Ud560 \\Uc218 \\Uc788\\Uace0 \\Ud589\\Ubcf5\\Ud574\\Uc9c8 \\Uc218 \\Uc788\\Ub2e4. \\Uadf8\\Ub7ec\\Uae30 \\Uc704\\Ud574\\Uc11c \\Ud544\\Uc694\\Ud55c \\Uac74 \\Uc624\\Uc9c1 \\Uc6a9\\Uae30\\Ubfd0\\Uc774\\Ub2e4. \\Uc790\\Uc720\\Ub85c\\Uc6cc\\Uc9c8 \\Uc6a9\\Uae30, \\Ud589\\Ubcf5\\Ud574\\Uc9c8 \\Uc6a9\\Uae30, \\Uadf8\\Ub9ac\\Uace0 \\Uc0ac\\Ub791\\Ud560 \\Uc6a9\\Uae30. \\Uc790\\Uc720\\Uc640 \\Ud589\\Ubcf5, \\Uc0ac\\Ub791\\Uacfc \\Uc9c4\\Uc815\\Ud55c";
            datetime = "2018-03-02T00:00:00.000+09:00";
            isbn = "1186560657 9791186560655";
            price = 19800;
            publisher = "\\Uc778\\Ud50c\\Ub8e8\\Uc5d4\\Uc15c";
            "sale_price" = 17820;
            status = "\\Uc815\\Uc0c1\\Ud310\\Ub9e4";
            thumbnail = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1630448%3Ftimestamp%3D20200513130057";
            title = "\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30(\\Ud2b9\\Ubcc4 \\Ud569\\Ubcf8\\Ud638)(\\Ud55c\\Uc815\\Ud310)(\\Uc591\\Uc7a5\\Ubcf8 HardCover)";
            translators =             (
                "\\Uc804\\Uacbd\\Uc544"
            );
            url = "https://search.daum.net/search?w=bookpage&bookId=1630448&q=%EB%AF%B8%EC%9B%80%EB%B0%9B%EC%9D%84+%EC%9A%A9%EA%B8%B0%28%ED%8A%B9%EB%B3%84+%ED%95%A9%EB%B3%B8%ED%98%B8%29%28%ED%95%9C%EC%A0%95%ED%8C%90%29%28%EC%96%91%EC%9E%A5%EB%B3%B8+HardCover%29";
        },
                {
            authors =             (
                "\\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c"
            );
            contents = "";
            datetime = "2017-09-01T00:00:00.000+09:00";
            isbn = "7111495489 9787111495482";
            price = 33500;
            publisher = "\\Uae30\\Uacc4\\Uacf5\\Uc5c5\\Ucd9c\\Ud310\\Uc0ac";
            "sale_price" = 24750;
            status = "\\Uc815\\Uc0c1\\Ud310\\Ub9e4";
            thumbnail = "";
            title = "\\Ud53c\\Ud1a0\\Uc5fc\\Uc801\\Uc6a9\\Uae30(\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30)";
            translators =             (
            );
            url = "https://search.daum.net/search?w=bookpage&bookId=3445642&q=%ED%94%BC%ED%86%A0%EC%97%BC%EC%A0%81%EC%9A%A9%EA%B8%B0%28%EB%AF%B8%EC%9B%80%EB%B0%9B%EC%9D%84+%EC%9A%A9%EA%B8%B0%29";
        },
                {
            authors =             (
                "\\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00"
            );
            contents = "\\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00\\Ub294 \\Uadf8\\Uc758 \\Ub300\\Ud45c\\Uc791\\Uc778 \\U300a\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30\\U300b\\Ub97c \\Uc4f4 \\Uac19\\Uc740 \\Ud574\\Uc5d0 \\Uc791\\Uac00\\Ub85c\\Uc11c \\Uadf8 \\Uad6c\\Uc131\\Ub825\\Uc744 \\Uc778\\Uc815\\Ubc1b\\Uc544 \\Ube44\\Uc988\\Ub2c8\\Uc2a4\\Uc11c \\Ub300\\Uc0c1 \\Uc2ec\\Uc0ac\\Uc704\\Uc6d0\\Ud2b9\\Ubcc4\\Uc0c1\\Uc744 \\Uc218\\Uc0c1\\Ud588\\Ub2e4. \\U300e\\Uc791\\Uac00\\Uc758 \\Ubb38\\Uc7a5\\Uc218\\Uc5c5\\U300f\\Uc740 \\Uadf8\\Uac00 15\\Ub144 \\Ub3d9\\Uc548 \\Ud604\\Uc7a5\\Uc5d0\\Uc11c \\Ubab8\\Uc18c \\Uacaa\\Uc73c\\Uba70 \\Ud130\\Ub4dd\\Ud55c \\Uae00\\Uc4f0\\Uae30 \\Ub178\\Ud558\\Uc6b0\\Ub97c \\Ub2f4\\Uc544\\Ub0b8 \\Ucc45\\Uc774\\Ub2e4. \\Uae00\\Uc744 \\Uc798 \\Uc4f0\\Uace0\\Uc790 \\Ud558\\Ub294 \\Ub9c8\\Uc74c\\Uac00\\Uc9d0\\Uc740 \\Uc81c\\Uccd0\\Ub450\\Uace0, \\Uc2e4\\Uc804\\Uc5d0\\Uc11c \\Ub2f9\\Uc7a5 \\Ub3c4\\Uc6c0\\Uc774 \\Ub418\\Ub294 \\Uc870\\Uc5b8\\Uc744 \\U2018\\Ub9ac\\Ub4ec\\U2019, \\U2018\\Uad6c\\Uc131\\U2019, \\U2018\\Ud3b8\\Uc9d1\\U2019\\Uc744 \\Uc8fc\\Uc81c\\Ub85c \\Uac15\\Uc758 \\Ud615\\Uc2dd\\Uc73c\\Ub85c \\Uc815\\Ub9ac\\Ud588\\Ub2e4.  \\Uc800\\Uc790\\Ub294 \\Uae00\\Uc4f0\\Uae30\\Ub97c \\U2018\\Uc791\\Uac00\\Uc758 \\Uba38\\Ub9bf\\Uc18d\\Uc5d0 \\Ub9f4\\Ub3c4\\Ub294 \\Uc774\\Uc57c\\Uae43\\Uac70\\Ub9ac\\Uac00 \\Ubc88\\Uc5ed \\Uc644\\Uc131\\Ub418\\Ub294 \\Uc77c";
            datetime = "2015-09-02T00:00:00.000+09:00";
            isbn = "8969520937 9788969520937";
            price = 3600;
            publisher = "\\Uacbd\\Ud5a5BP";
            "sale_price" = 3240;
            status = "\\Uc815\\Uc0c1\\Ud310\\Ub9e4";
            thumbnail = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F949019%3Ftimestamp%3D20200803132250";
            title = "\\Uc791\\Uac00\\Uc758 \\Ubb38\\Uc7a5\\Uc218\\Uc5c5(\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30 \\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00)";
            translators =             (
                "\\Uc815\\Uc5f0\\Uc8fc"
            );
            url = "https://search.daum.net/search?w=bookpage&bookId=949019&q=%EC%9E%91%EA%B0%80%EC%9D%98+%EB%AC%B8%EC%9E%A5%EC%88%98%EC%97%85%28%EB%AF%B8%EC%9B%80%EB%B0%9B%EC%9D%84+%EC%9A%A9%EA%B8%B0+%EA%B3%A0%EA%B0%80+%ED%9B%84%EB%AF%B8%ED%83%80%EC%BC%80%29";
        },
                {
            authors =             (
                "\\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c"
            );
            contents = "\\U300e\\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc744 \\Uc77d\\Ub294 \\Ubc24\\U300f\\Uc740 \\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc5d0 \\Uad00\\Ud55c \\Uc77c\\Ubcf8\\Uc758 1\\Uc778\\Uc790 \\Ucca0\\Ud559\\Uc790 \\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c\\Uc640 \\Ubca0\\Uc2a4\\Ud2b8\\Uc140\\Ub7ec \\Uc791\\Uac00\\Uc778 \\Uace0\\Uac00 \\Ud6c4\\Ubbf8\\Ud0c0\\Ucf00\\Uac00 \\Uacf5\\Uc800\\Ud55c \\U300a\\Ubbf8\\Uc6c0\\Ubc1b\\Uc744 \\Uc6a9\\Uae30\\U300b\\Uc758 \\Uc6d0\\Uc804\\Uc774 \\Ub41c \\Ucc45\\Uc774\\Ub2e4. \\Uc800\\Uc790 \\Uae30\\Uc2dc\\Ubbf8 \\Uc774\\Uce58\\Ub85c\\Uac00 \\Uc6b0\\Uc5f0\\Ud788 \\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc5d0 \\Ube60\\Uc838\\Ub4e4\\Uac8c \\Ub418\\Uba74\\Uc11c \\Uae68\\Ub2eb\\Uac8c \\Ub41c \\Uc9c0\\Uc2dd\\Uacfc \\Ud1b5\\Ucc30, \\Uadf8\\Ub9ac\\Uace0 \\Uc218\\Ub9ce\\Uc740 \\Uc0c1\\Ub2f4\\Uc744 \\Ud1b5\\Ud574 \\Uc5bb\\Uc740 \\Uc784\\Uc0c1 \\Uacbd\\Ud5d8\\Uacfc \\Uc0ac\\Ub840\\Ub4e4 \\Uc911\\Uc5d0\\Uc11c \\U2018\\Uc815\\Uc218\\U2019\\Ub9cc\\Uc744 \\Uc815\\Ub9ac\\Ud574\\Uc11c \\Uba85\\Ucf8c\\Ud558\\Uac8c \\Uc124\\Uba85\\Ud558\\Uace0 \\Uc788\\Ub2e4.  \\Uadf8\\Ub807\\Ub2e4\\Uba74 \\Uc65c \\Uc9c0\\Uae08 \\Uc544\\Ub4e4\\Ub7ec\\Uc77c\\Uae4c? \\Uc544\\Ub4e4\\Ub7ec\\Ub97c \\Ud754\\Ud788 \\U2018\\Uc6a9\\Uae30\\Uc758 \\Uc2ec\\Ub9ac\\Ud559\\Uc790\\U2019\\Ub77c\\Uace0 \\Ubd80\\Ub974\\Ub294 \\Ub370\\Uc11c \\Uadf8 \\Uc774\\Uc720\\Ub97c";
            datetime = "2015-01-15T00:00:00.000+09:00";
            isbn = "8952230647 9788952230645";
            price = 13800;
            publisher = "\\Uc0b4\\Ub9bc";
            "sale_price" = 12420;
            status = "\\Uc815\\Uc0c1\\Ud310\\Ub9e4";
            thumbnail = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F635470%3Ftimestamp%3D20200803132136";
            title = "\\Uc544\\Ub4e4\\Ub7ec \\Uc2ec\\Ub9ac\\Ud559\\Uc744 \\Uc77d\\Ub294 \\Ubc24";
            translators =             (
                "\\Ubc15\\Uc7ac\\Ud604"
            );
            url = "https://search.daum.net/search?w=bookpage&bookId=635470&q=%EC%95%84%EB%93%A4%EB%9F%AC+%EC%8B%AC%EB%A6%AC%ED%95%99%EC%9D%84+%EC%9D%BD%EB%8A%94+%EB%B0%A4";
        }
    );
    meta =     {
        "is_end" = 0;
        "pageable_count" = 13;
        "total_count" = 14;
    };
}
""".data(using: .utf8)!
