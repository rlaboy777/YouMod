// Settings.x
// Thanks to the original codes from YTUHD by PoomSmart - https://github.com/PoomSmart/YTUHD/blob/0e735616fd8fc6546339da7fdc78466f16f23ffd/Settings.x
#import "Headers.h"

#define TweakName @"YouMod"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

static const NSInteger TweakSection = 'ytmo';

@interface YTSettingsSectionItemManager (YouMod)
- (void)updateYouModSectionWithEntry:(id)entry;
@end

NSBundle *YouModBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:TweakName ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:PS_ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), TweakName]];
    });
    return bundle;
}

// Settings Search Bar
%hook YTSettingsViewController
- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == TweakSection)
        [self setValue:@(YES) forKey:@"_shouldShowSearchBar"];
}
- (void)setSectionControllers {
    %orig;
    BOOL showSearchBar = [[self valueForKey:@"_shouldShowSearchBar"] boolValue];
    if (showSearchBar) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        if (settingsSectionController)
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    }
}
%end

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(TweakSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(TweakSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYouModSectionWithEntry:(id)entry {
    NSMutableArray <YTSettingsSectionItem *> *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouModBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    // Tweak Version (at the top)
    // Thanks to the original codes from YTweaks by fosterbarnes - https://github.com/fosterbarnes/YTweaks/blob/e921591a89b87256a2b37c4788bd99282f70d9c2/Settings.x
    YTSettingsSectionItem *tweakVersion = [YTSettingsSectionItemClass itemWithTitle:@"YouMod v1.0.0"
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:tweakVersion];

    // Section 0
    // Github
    YTSettingsSectionItem *github = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:@"Github"
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:github];

    // Issues
    YTSettingsSectionItem *issues = [YTSettingsSectionItemClass itemWithTitle:LOC(@"NEW_ISSUES")
        titleDescription:LOC(@"NEW_ISSUES_DESC") // Found bug or Feature request -> Report Issues
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Tonwalter888/YouMod/issues/new"]];
        }
    ];
    [sectionItems addObject:issues];

    // Sources codes
    YTSettingsSectionItem *sourceCodes = [YTSettingsSectionItemClass itemWithTitle:LOC(@"SOURCE_CODES")
        titleDescription:LOC(@"SOURCE_CODES_DESC") // Take a look
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Tonwalter888/YouMod"]];
        }
    ];
    [sectionItems addObject:sourceCodes];

    /*
    // Perference Mgr - NEEDS TO DO THE LOGIC
    YTSettingsSectionItem *github = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:@"Github"
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:github];
    */ 

    // Section 1
    // Navigation bar
    YTSettingsSectionItem *navbar = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"NAVBAR")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:navbar];

    // Hide YT logo
    YTSettingsSectionItem *hideytlogo = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YT_LOGO")
        titleDescription:LOC(@"HIDE_YT_LOGO_DESC") // Hide the logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideYTLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideYTLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideytlogo];

    /*
    // Center YT logo
    YTSettingsSectionItem *centerytlogo = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CENTER_YT_LOGO")
        titleDescription:LOC(@"CENTER_YT_LOGO_DESC") // Set center logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(CenterYTLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:CenterYTLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:centerytlogo];
    */

    // YT Premium logo
    YTSettingsSectionItem *ytpremium = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"PREMIUM_LOGO")
        titleDescription:LOC(@"PREMIUM_LOGO_DESC") // Change to premium logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(YTPremiumLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:YTPremiumLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:ytpremium];

    // Hide Notification button
    YTSettingsSectionItem *hidenoti = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATION_BUTTON")
        titleDescription:LOC(@"HIDE_NOTIFICATION_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideNoti)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideNoti];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidenoti];

    // Hide Search button
    YTSettingsSectionItem *hidesearch = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SEARCH_BUTTON")
        titleDescription:LOC(@"HIDE_SEARCH_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSearch)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSearch];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesearch];

    // Hide Voice Search button
    YTSettingsSectionItem *hidevoicesearch = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_VOICE_SEARCH_BUTTON")
        titleDescription:LOC(@"HIDE_VOICE_SEARCH_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideVoiceSearch)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideVoiceSearch];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidevoicesearch];

    // Hide Cast button
    YTSettingsSectionItem *hidecastbuttonnav = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAST_BUTTON_NAVBAR")
        titleDescription:LOC(@"HIDE_CAST_BUTTON_NAVBAR_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideCastButtonNav)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideCastButtonNav];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidecastbuttonnav];

    // Section 2
    // Feed
    YTSettingsSectionItem *feed = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"FEED")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:feed];

    // Hide Subbar
    YTSettingsSectionItem *hidesubbar = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBBAR")
        titleDescription:LOC(@"HIDE_SUBBAR_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSubbar)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSubbar];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesubbar];

    // Hide Horizonal Shelf
    YTSettingsSectionItem *hidehorishelf = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HORIZONTAL_SHELF")
        titleDescription:LOC(@"HIDE_HORIZONTAL_SHELF_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideHoriShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideHoriShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidehorishelf];

    // Hide Music Playlist Generator
    YTSettingsSectionItem *hidemusicgen = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MUSIC_PLAYLISTS")
        titleDescription:LOC(@"HIDE_MUSIC_PLAYLISTS_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideGenMusicShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideGenMusicShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidemusicgen];

    // Hide Shorts Shelf
    YTSettingsSectionItem *hideshortsself = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_SHELF")
        titleDescription:LOC(@"HIDE_SHORTS_SHELF_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideShortsShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideShortsShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideshortsself];

    // Section 3
    // Player
    YTSettingsSectionItem *player = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"PLAYER")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:player];

    // Hide autoplay toggle
    YTSettingsSectionItem *hideautoplaytoggle = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_AUTOPLAY")
        titleDescription:LOC(@"HIDE_AUTOPLAY_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideAutoPlayToggle)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideAutoPlayToggle];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideautoplaytoggle];

    // Hide captions button
    YTSettingsSectionItem *hidecaptionsbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAPTIONS_BUTTON")
        titleDescription:LOC(@"HIDE_CAPTIONS_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideCaptionsButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideCaptionsButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidecaptionsbutton];

    // Hide cast button
    YTSettingsSectionItem *hidecastbuttonplayer = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAST_BUTTON_PLAYER")
        titleDescription:LOC(@"HIDE_CAST_BUTTON_PLAYER_DESC") // NOTE
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideCastButtonPlayer)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideCastButtonPlayer];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidecastbuttonplayer];

    // Hide previous button
    YTSettingsSectionItem *hideprevbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PREV_BUTTON")
        titleDescription:LOC(@"HIDE_PREV_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HidePrevButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HidePrevButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideprevbutton];

    // Hide next button
    YTSettingsSectionItem *hidenextbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NEXT_BUTTON")
        titleDescription:LOC(@"HIDE_NEXT_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideNextButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideNextButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidenextbutton];

    // Remove dark overlay
    YTSettingsSectionItem *removedarkoverlay = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"REMOVE_DARK_OVERLAY")
        titleDescription:LOC(@"REMOVE_DARK_OVERLAY_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(RemoveDarkOverlay)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:RemoveDarkOverlay];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:removedarkoverlay];

    // Hide endscreen cards
    YTSettingsSectionItem *hideendscreencards = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_END_SCREEN")
        titleDescription:LOC(@"HIDE_END_SCREEN_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideEndScreenCards)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideEndScreenCards];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideendscreencards];

    // Hide channel watermark
    YTSettingsSectionItem *hidewatermark = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_WATERMARK")
        titleDescription:LOC(@"HIDE_WATERMARK_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideWaterMark)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideWaterMark];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidewatermark];

    // Disables double tap
    YTSettingsSectionItem *disablesdoubletap = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLES_DOUBLE_TAP")
        titleDescription:LOC(@"DISABLES_DOUBLE_TAP_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(DisablesDoubleTap)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:DisablesDoubleTap];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:disablesdoubletap];

    // Disables long hold
    YTSettingsSectionItem *diableslonghold = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLES_LONG_HOLD")
        titleDescription:LOC(@"DISABLES_LONG_HOLD_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(DisablesLongHold)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:DisablesLongHold];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:diableslonghold];

    // Exit fullscreen when finished playing video
    YTSettingsSectionItem *autoexitfullscreen = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"AUTO_EXIT_FULLSCREEN")
        titleDescription:LOC(@"AUTO_EXIT_FULLSCREEN_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(AutoExitFullScreen)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:AutoExitFullScreen];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:autoexitfullscreen];

    // Hide like button
    YTSettingsSectionItem *hidelikebutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_LIKE_BUTTON")
        titleDescription:LOC(@"HIDE_LIKE_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideLikeButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideLikeButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidelikebutton];

    // Hide dislike button
    YTSettingsSectionItem *hidedislikebutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_DISLIKE_BUTTON")
        titleDescription:LOC(@"HIDE_DISLIKE_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideDisLikeButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideDisLikeButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidedislikebutton];

    // Hide share button
    YTSettingsSectionItem *hidesharebutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHARE_BUTTON")
        titleDescription:LOC(@"HIDE_SHARE_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideShareButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideShareButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesharebutton];

    // Hide download button
    YTSettingsSectionItem *hidedownloadbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_DOWNLOAD_BUTTON")
        titleDescription:LOC(@"HIDE_DOWNLOAD_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideDownloadButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideDownloadButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidedownloadbutton];

    // Hide clip button
    YTSettingsSectionItem *hideclipbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CLIP_BUTTON")
        titleDescription:LOC(@"HIDE_CLIP_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideClipButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideClipButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideclipbutton];

    // Hide remix button
    YTSettingsSectionItem *hideremixbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_REMIX_BUTTON")
        titleDescription:LOC(@"HIDE_REMIX_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideRemixButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideRemixButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideremixbutton];

    // Hide save button
    YTSettingsSectionItem *hidesavebutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SAVE_BUTTON")
        titleDescription:LOC(@"HIDE_SAVE_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSaveButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSaveButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesavebutton];

    /*
    // Hide comment section
    YTSettingsSectionItem *hidedownloadbutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_DOWNLOAD_BUTTON")
        titleDescription:LOC(@"HIDE_DOWNLOAD_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideDownloadButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideDownloadButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidedownloadbutton];
    */

    // Section 4
    // Tab bar
    YTSettingsSectionItem *tabbar = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"TABBAR")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:tabbar];

    /* Default tab - Later
    YTSettingsSectionItem *hideshortsself = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_SHELF")
        titleDescription:LOC(@"HIDE_SHORTS_SHELF_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideShortsShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideShortsShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideshortsself];
    */

    // Hide tab indicators
    YTSettingsSectionItem *hidetabindi = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_TAB_INDI")
        titleDescription:LOC(@"HIDE_TAB_INDI_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideTabIndi)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideTabIndi];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidetabindi];

    // Hide tab labels
    YTSettingsSectionItem *hidetablabels = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_TAB_LABELS")
        titleDescription:LOC(@"HIDE_TAB_LABELS_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideTabLabels)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideTabLabels];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidetablabels];

    // Hide home tab
    YTSettingsSectionItem *hidehometab = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HOME_TAB")
        titleDescription:LOC(@"HIDE_HOME_TAB_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideHomeTab)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideHomeTab];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidehometab];

    // Hide Shorts tab
    YTSettingsSectionItem *hideshortstab = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_TAB")
        titleDescription:LOC(@"HIDE_SHORTS_TAB_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideShortsTab)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideShortsTab];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideshortstab];

    // Hide Create button
    YTSettingsSectionItem *hidecreatebutton = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CREATE_BUTTON")
        titleDescription:LOC(@"HIDE_CREATE_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideCreateButton)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideCreateButton];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidecreatebutton];

    // Hide Subscriptions tab
    YTSettingsSectionItem *hidesubscripttab = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBSCRIPT_TAB")
        titleDescription:LOC(@"HIDE_SUBSCRIPT_TAB_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSubscriptTab)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSubscriptTab];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesubscripttab];

    // More coming soon...

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_TUNE;
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName icon:icon titleDescription:nil headerHidden:NO];
    } else
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == TweakSection) {
        [self updateYouModSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end
