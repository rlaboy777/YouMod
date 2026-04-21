// All codes are adapt from YTLite
#import "Headers.h"

%hook YTIElementRenderer
- (NSData *)elementData {
    // if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && ytlBool(@"noAds")) return nil;

    NSString *description = [self description];

    // Use YouTube-X
    // NSArray *ads = @[@"brand_promo", @"product_carousel", @"product_engagement_panel", @"product_item", @"text_search_ad", @"text_image_button_layout", @"carousel_headered_layout", @"carousel_footered_layout", @"square_image_layout", @"landscape_image_wide_button_layout", @"feed_ad_metadata"];
    // if (ytlBool(@"noAds") && [ads containsObject:description]) {
    //    return [NSData data];
    // }

    NSArray *shortsToRemove = @[@"shorts_shelf.eml", @"shorts_video_cell.eml", @"6Shorts", @"eml.shorts-shelf"];
    for (NSString *shorts in shortsToRemove) {
        if (HideShortsSection() && [description containsString:shorts] && ![description containsString:@"history*"]) {
            return nil;
        }
    }

    return %orig;
}
%end

// Hide Navigation Bar Buttons
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig;

    if (HideNoti()) self.notificationButton.hidden = YES;
    if (HideSearch()) self.searchButton.hidden = YES;

    for (UIView *subview in self.subviews) {
        // if (NoVoiceSearch() && [subview.accessibilityLabel isEqualToString:NSLocalizedString(@"search.voice.access", nil)]) subview.hidden = YES;
        if (NoCast() && [subview.accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"]) subview.hidden = YES;
    }
}
%end

%hook YTSearchViewController
- (void)viewDidLoad {
    %orig;
    if (NoVoiceSearch()) [self setValue:@(NO) forKey:@"_isVoiceSearchAllowed"];
}
- (void)setSuggestions:(id)arg1 { if !(NoSearchHistory()) %orig; }
%end

%hook YTPersonalizedSuggestionsCacheProvider
- (id)activeCache { return NoSearchHistory() ? nil : %orig; }
%end

// Hide Subbar
%hook YTMySubsFilterHeaderView
- (void)setChipFilterView:(id)arg1 { if !(NoSubbar()) %orig; }
%end

%hook YTHeaderContentComboView
- (void)enableSubheaderBarWithView:(id)arg1 { if !(NoSubbar()) %orig; }
- (void)setFeedHeaderScrollMode:(int)arg1 { NoSubbar() ? %orig(0) : %orig; }
%end

%hook YTChipCloudCell
- (void)layoutSubviews {
    if (self.superview && NoSubbar()) {
        [self removeFromSuperview];
    } %orig;
}
%end

%hook YTMainAppControlsOverlayView
// Hide Autoplay Switch
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { if !(HideAutoPlay()) %orig; }

// Hide Subs Button
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 { HideCaptions() ? %orig(NO) : %orig; }

// - (void)setVoiceOverEnabled:(BOOL)arg1
// Hide YouTube Music button
- (void)setYoutubeMusicButton:(id)arg1 { if !(HideYTMButton()) %orig; }
%end

// Prevent YouTube from asking to update the app
%group Upgrade
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES; }
- (BOOL)shouldShowUpgradeDialog { return NO; }
- (BOOL)shouldShowUpgrade { return NO; }
- (BOOL)shouldForceUpgrade { return NO; }
%end
%end

// Prevent YouTube from asking "Are you there?"
%group AreYouThere
%hook YTColdConfig
- (BOOL)enableYouthereCommandsOnIos { return NO; }
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return NO; }
- (void)showYouTherePrompt {}
%end

%hook YTYouThereControllerImpl
- (BOOL)shouldShowYouTherePrompt { return NO; }
- (void)showYouTherePrompt {}
%end
%end

%group SlowMiniPlayer
%hook YTColdConfig
- (BOOL)enableIosFloatingMiniplayerDoubleTapToResize { return NO; }
%end
%end

%group OldMiniPlayer
%hook YTColdConfig
- (BOOL)enableIosFloatingMiniplayer { return NO; }
%end

%hook YTColdConfigWatchPlayerClientGlobalConfigImpl
- (BOOL)enableIosFloatingMiniplayer { return NO; }
%end
%end

// Disables Snackbar
%group SnackBar
%hook GOOHUDManagerInternal
- (id)sharedInstance { return nil; }
- (void)showMessageMainThread:(id)arg {}
- (void)activateOverlay:(id)arg {}
- (void)displayHUDViewForMessage:(id)arg {}
%end
%end

// Try to disable Shorts PiP
%group DisablesShortsPiP
%hook YTColdConfig
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPicture { return NO; }
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPictureIos { return NO; }
%end

%hook YTHotConfig
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPictureAllowedFromPlayer { return NO; }
%end

%hook YTReelModel
- (BOOL)isPiPSupported { return NO; }
%end

%hook YTReelPlayerViewController
- (BOOL)isPictureInPictureAllowed { return NO; }
%end

%hook YTReelWatchRootViewController
- (void)switchToPictureInPicture {}
%end
%end

// Remove Dark Background in Overlay
%hook YTMainAppVideoPlayerOverlayView
- (void)setBackgroundVisible:(BOOL)arg1 isGradientBackground:(BOOL)arg2 { NoDarkBackGround() ? %orig(NO, arg2) : %orig; }
%end

// No Endscreen Cards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)arg1 { NoEndScreen() ? %orig(YES) : %orig; }
- (void)setHoverCardHidden:(BOOL)arg { NoEndScreen() ? %orig(YES) : %orig; }
- (void)setHoverCardRenderer:(id)arg { if !(NoEndScreen()) %orig; }
%end

// Disable Fullscreen Actions
%hook YTFullscreenActionsView
- (BOOL)enabled { return NoFSActions() ? NO : %orig; }
- (void)setEnabled:(BOOL)arg1 { NoFSActions() ? %orig(NO) : %orig; }
%end

%hook YTInlinePlayerBarContainerView
- (void)setPlayerBarAlpha:(CGFloat)alpha { PersistentProgressBar() ? %orig(1.0) : %orig; }
%end

// Remove Watermarks
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark { if (!NoWatermarks()) %orig; }
%end

%hook YTMainAppVideoPlayerOverlayView
- (BOOL)isWatermarkEnabled { return NoWatermarks() ? NO : %orig; }
- (void)setWatermarkEnabled:(BOOL)arg { NoWatermarks() ? %orig(NO) : %orig; }
%end

// Forcibly Enable Miniplayer
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer { if (!ForceMiniPLayer()) %orig; }
%end

%hook YTWatchFloatingMiniplayerViewController
- (void)updateMiniBarPlayerStateFromRenderer { if (!ForceMiniPLayer()) %orig; }
%end

// Portrait Fullscreen
%hook YTWatchViewController
- (unsigned long long)allowedFullScreenOrientations { return PortraitFullscreen() ? UIInterfaceOrientationMaskAllButUpsideDown : %orig; }
%end

// Disable Autoplay
%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1 { NoAutoPlay() ? %orig(NO) : %orig; }
%end

// Skip Content Warning (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L452-L454)
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { NoContentWarning() ? [self confirmAlertDidPressConfirm] : %orig; }
%end

%hook YTPlayabilityResolutionUserActionUIControllerImpl
- (void)showConfirmAlert { NoContentWarning() ? [self confirmAlertDidPressConfirm] : %orig; }
%end

// Dont Show Related Videos on Finish
%hook YTFullscreenEngagementOverlayController
- (void)setRelatedVideosVisible:(BOOL)arg1 { NoRelatedVids() ? %orig(NO) : %orig; }
%end

// Disable Snap To Chapter (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L457-464)
// %hook YTSegmentableInlinePlayerBarView
// - (void)didMoveToWindow { %orig; if (ytlBool(@"dontSnapToChapter")) self.enableSnapToChapter = NO; }
// %end

// Disable Hints
%hook YTSettings
- (BOOL)areHintsDisabled { return NoHints() ? YES : %orig; }
- (void)setHintsDisabled:(BOOL)arg1 { NoHints() ? %orig(YES) : %orig; }
%end

%hook YTSettingsImpl
- (BOOL)areHintsDisabled { return NoHints() ? YES : %orig; }
- (void)setHintsDisabled:(BOOL)arg1 { NoHints() ? %orig(YES) : %orig; }
%end

%hook YTUserDefaults
- (BOOL)areHintsDisabled { return NoHints() ? YES : %orig; }
- (void)setHintsDisabled:(BOOL)arg1 { NoHints() ? %orig(YES) : %orig; }
%end

/* Wait for now
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig;
    if (ytlBool(@"autoFullscreen")) [self performSelector:@selector(autoFullscreen) withObject:nil afterDelay:0.75];
    if (ytlBool(@"shortsToRegular")) [self performSelector:@selector(shortsToRegular) withObject:nil afterDelay:0.75];
    if (ytlBool(@"disableAutoCaptions")) [self performSelector:@selector(turnOffCaptions) withObject:nil afterDelay:1.0];
}

%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}

%new
- (void)shortsToRegular {
    if (self.contentVideoID != nil && [self.parentViewController isKindOfClass:NSClassFromString(@"YTShortsPlayerViewController")]) {
        NSString *vidLink = [NSString stringWithFormat:@"vnd.youtube://%@", self.contentVideoID];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:vidLink]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vidLink] options:@{} completionHandler:nil];
        }
    }
}

%new
- (void)turnOffCaptions {
    if ([self.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) {
        [self setActiveCaptionTrack:nil];
    }
}

- (void)singleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;

    addEndTime(self, video, time);
    autoSkipShorts(self, video, time);
}

- (void)potentiallyMutatedSingleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;

    addEndTime(self, video, time);
    autoSkipShorts(self, video, time);
}
%end

// Fix Playlist Mini-bar Height For Small Screens
%hook YTPlaylistMiniBarView
- (void)setFrame:(CGRect)frame {
    if (frame.size.height < 54.0) frame.size.height = 54.0;
    %orig(frame);
}
%end
*/

// Remove "Play next in queue" from the menu @PoomSmart (https://github.com/qnblackcat/uYouPlus/issues/1138#issuecomment-1606415080)
%hook YTMenuItemVisibilityHandler
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    if (RemovePlayNext() && renderer.icon.iconType == 251) {
        return NO;
    } return %orig;
}
%end

%hook YTMenuItemVisibilityHandlerImpl
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    if (RemovePlayNext() && renderer.icon.iconType == 251) {
        return NO;
    } return %orig;
}
%end

// Exit Fullscreen on Finish
%hook YTWatchFlowController
- (BOOL)shouldExitFullScreenOnFinish { return ExitFullscreen() ? YES : %orig; }
%end

%hook YTMainAppVideoPlayerOverlayViewController
// Disable Double Tap To Seek
- (BOOL)allowDoubleTapToSeekGestureRecognizer { return NoDoubleTapToSeek() ? NO : %orig; }
// Disable long hold
- (BOOL)allowLongPressGestureRecognizerInView:(id)arg { return NoLongHold() ? NO : %orig; }
// Disable Two Finger Double Tap
- (BOOL)allowTwoFingerDoubleTapGestureRecognizer { return NoTwoFingerSnapToChapter() ? NO : %orig; }
%end

/*
// Remove Download button from the menu
%hook YTDefaultSheetController
- (void)addAction:(YTActionSheetAction *)action {
    NSString *identifier = [action valueForKey:@"_accessibilityIdentifier"];

    NSDictionary *actionsToRemove = @{
        @"7": @(ytlBool(@"removeDownloadMenu")),
        @"1": @(ytlBool(@"removeWatchLaterMenu")),
        @"3": @(ytlBool(@"removeSaveToPlaylistMenu")),
        @"5": @(ytlBool(@"removeShareMenu")),
        @"12": @(ytlBool(@"removeNotInterestedMenu")),
        @"31": @(ytlBool(@"removeDontRecommendMenu")),
        @"58": @(ytlBool(@"removeReportMenu"))
    };

    if (![actionsToRemove[identifier] boolValue]) {
        %orig;
    }
}
%end
*/

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];
    
    // We use an IndexSet to "mark" the buttons for deletion
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];

    // Loop through every item in the bar
    for (NSUInteger i = 0; i < items.count; i++) {
        YTIPivotBarSupportedRenderers *item = items[i];
        NSString *pID = [[item pivotBarItemRenderer] pivotIdentifier];

        // If the ID matches any of these, mark it for removal
        if ([pID isEqualToString:@"FEshorts"] && HideShorts()) {
            [indicesToRemove addIndex:i];
        }
        if ([pID isEqualToString:@"FEuploads"] && HideCreate()) {
            [indicesToRemove addIndex:i];
        }
        if ([pID isEqualToString:@"FEsubscriptions"] && HideSubscript()) {
            [indicesToRemove addIndex:i];
        }
        if ([pID isEqualToString:@"FEwhat_to_watch"] && HideHome()) {
            [indicesToRemove addIndex:i];
        }
    }

    // Remove them all at once so the layout doesn't break
    [items removeObjectsAtIndexes:indicesToRemove];
    
    %orig(renderer);
}
%end